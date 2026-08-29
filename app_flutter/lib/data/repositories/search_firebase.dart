// ─────────────────────────────────────────────────────────────────────────────
// FirebaseSearchRepository — the Layer-B (server) implementation of
// [SearchRepository]. Pillar 5 · Step 63 (R1-7 canonical). The step-62 skeleton
// grew its real body here: a TOKEN-NARROW over the neutral paged catalog seam
// followed by the SAME `fuzzySearchProducts` re-rank — an ANSWER-EQUIVALENT top-N
// (never a byte-identical ranking claim). A DROP-IN for [LocalSearchRepository]:
// the eventual consumers + the provider are unchanged — only which class
// `searchRepositoryProvider` returns changes (see the switch in `search_local.dart`).
//
// THE LAYER-B BODY (exactly what step 63's detail names, adapted to current code):
//   1. NARROW — derive the answer-equivalence-SAFE narrowing token from the query
//      ([catalogNarrowToken]) and fetch the candidate page whose `nameTokens`
//      array contains it, through the neutral [CatalogTokenIndex] port. The port
//      speaks only decoded models — it imports NO `cloud_firestore`; the real
//      `arrayContains` query lives behind the one adapter that may
//      (`authored_products_firebase.dart`, the S3.K authored-catalog seam), so
//      this file stays Firebase-free exactly like the step-62 skeleton.
//   2. RE-RANK — feed that small candidate page to the SAME live ranker,
//      `fuzzySearchProducts(query, products: candidates)` (`fuzzy_search.dart:16`).
//      Because the narrowing token is a 3-gram GUARANTEED to be a superset filter
//      (see [catalogNarrowToken]), the top-N is ANSWER-EQUIVALENT to the Layer-A
//      full scan (R1-7) — the multi-word AND, the proximity ranking, and the cap
//      are all the verbatim local ranker, just over fewer rows.
//
// DEGRADE-TO-LAYER-A (never blank — the R2-7 spirit + the step-63 DoD
// "`CATALOG_SERVER_SEARCH` OFF → Layer-A"): on ANY of —
//   • no [CatalogTokenIndex] wired (the shipped default — the impl is DORMANT),
//   • a query that cannot be safely narrowed (no word ≥ 3 chars → no 3-gram),
//   • an EMPTY candidate page (the token indexed nothing), or
//   • the port THROWING (offline / permission-denied / not-deployed)
// — [search] falls back to the VERBATIM Layer-A scan
// (`fuzzySearchProducts`), so a premature flag-flip yields HONEST results (the
// proven local ranking), never a blank/empty page.
//
// DORMANT / byte-identical when OFF: the default `const FirebaseSearchRepository()`
// carries a NULL index, so it degrades to Layer-A on every call — and the provider
// only ever returns this class when [useCatalogServerSearch] is true
// (`kCatalogServerSearch && useFirebaseBackend`, both OFF by default). NOTHING wires
// a real [CatalogTokenIndex] yet: the live `arrayContains` adapter lands in a later
// wiring step (after the `nameTokens` composite index + the
// `onCatalogProductWrite` indexer are deployed — step 68 deploy-ordering), inside
// the authored-catalog adapter, never here. Until then the OFF/degraded path is
// byte-identical to today.
//
// FIREBASE-FREE by construction: this file imports NO `cloud_firestore` — the
// token-narrow reaches the collection through the NEUTRAL [CatalogTokenIndex]
// port, so the live handle stays behind the one real adapter, exactly as the base
// fleet keeps it (asserted by `search_repository_test.dart`).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/fuzzy_search.dart' show fuzzySearchProducts;
import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/data/paged_query.dart' show Cursor;
import 'package:buildsmart/data/repositories/search_repository.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture, debugPrint;

/// The NEUTRAL token-index read-port the Layer-B search narrows over. ONE
/// question — "give me the catalog products whose server-built `nameTokens`
/// contains [token]" — so the whole server body is driven by a hand-rolled fake
/// in tests (the define-less-fake idiom), and only the real adapter imports a live
/// `cloud_firestore`.
///
/// The real adapter (DORMANT — wired in a later step, inside the authored-catalog
/// seam `authored_products_firebase.dart`, the only file allowed to touch
/// Firestore under S3.K) runs
/// `catalogProducts.where('nameTokens', arrayContains: token).orderBy('nameHe')
/// .limit(limit)` and maps each row through
/// `FirebaseAuthoredProductsRepository.fromDoc`, returning decoded models. Speaking
/// decoded [LipskeyCatalogProduct]s (not a Firestore snapshot / neutral doc) keeps
/// THIS file free of any `cloud_firestore` import AND free of mapper duplication —
/// the re-rank below is pure ranking.
// A deliberate one-member seam — a token index answers exactly one question.
// ignore: one_member_abstracts
abstract class CatalogTokenIndex {
  /// The catalog products whose server-built `nameTokens` array contains [token]
  /// (the query's narrowing 3-gram), ordered by `nameHe`, capped at [limit]. An
  /// empty list means the token indexed nothing — the caller then DEGRADES to the
  /// full Layer-A scan (never blank).
  Future<List<LipskeyCatalogProduct>> candidatesForToken(
    String token, {
    required int limit,
  });
}

/// The answer-equivalence-SAFE narrowing token for [query] (R1-7), or null when
/// the query cannot be safely narrowed — in which case the caller DEGRADES to the
/// full Layer-A scan rather than risk missing a match.
///
/// WHY A 3-GRAM (not the whole word): the live `fuzzySearchProducts`
/// (`fuzzy_search.dart:16`) matches a query word as a SUBSTRING of `nameHe`, and
/// the step-63 indexer emits `nameTokens` = words + 3-grams of `nameHe` (nameHe
/// ONLY, lowercased — parity with the live ranker, R1-7). A query word's LEADING
/// 3-gram is a substring of EVERY product that contains that word, so it is
/// guaranteed to be one of that product's 3-gram tokens ⇒ the `arrayContains`
/// candidate set is a SUPERSET of the Layer-A match set ⇒ the fuzzy re-rank over
/// the candidates is ANSWER-EQUIVALENT to the full scan. A 4+-char WHOLE word
/// would instead MISS a substring-only match (it is neither a whole word nor a
/// 3-gram of the longer host string), silently breaking parity.
///
/// WHICH word: the LONGEST — a rarity PROXY (longer words are rarer, so we narrow
/// on the most selective one and let the re-rank apply the remaining words
/// client-side). True frequency-rarity via the server `catalogTokenFreq` is a
/// later refinement; the choice is EFFICIENCY-only — correctness (the superset)
/// holds for ANY query word's leading 3-gram, and an empty candidate page always
/// degrades to Layer-A. Query words are lowercased + whitespace-split exactly like
/// the live ranker, so the narrowing token lines up with what it will re-rank.
String? catalogNarrowToken(String query) {
  final words = query
      .trim()
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isEmpty) return null;
  var longest = '';
  for (final w in words) {
    if (w.length > longest.length) longest = w; // first-wins on a length tie
  }
  // Shorter than a 3-gram → no safe token → degrade to the full scan.
  if (longest.length < 3) return null;
  return longest.substring(0, 3);
}

/// The Firestore-backed (Layer-B) implementation of [SearchRepository] (Step 63).
/// Narrows candidates by the rarest `nameTokens` 3-gram over the neutral
/// [CatalogTokenIndex] port, then RE-RANKS that small page with the SAME
/// `fuzzySearchProducts` — an ANSWER-EQUIVALENT top-N (R1-7). On any failure / OFF
/// it DEGRADES to the verbatim Layer-A scan (never blank).
class FirebaseSearchRepository implements SearchRepository {
  /// [index] is the token-narrow port — injected as a fake in tests. The default
  /// is NULL (the shipped/dormant state): with no index every [search] degrades to
  /// Layer-A, so a flag-flip before the real adapter is wired yields honest local
  /// results, never blank. `const` so the provider's default is a compile-time const.
  const FirebaseSearchRepository({CatalogTokenIndex? index}) : _index = index;

  final CatalogTokenIndex? _index;

  /// The candidate page size fetched from the token index — the §6 cost guardrail,
  /// the same 40 cap as `PagedQuery.maxLimit` / the real query's `.limit(40)`. The
  /// re-rank then applies the caller's own [search] `limit` to the page.
  static const int candidatePageSize = 40;

  /// Layer-B search: narrow → re-rank, degrading to Layer-A on any failure / OFF.
  /// [after] is accepted for signature parity but ignored — the token-narrowed
  /// candidate page is single-page in this step (a future multi-page narrow would
  /// thread the cursor). With no [index] wired this returns the Layer-A
  /// [SynchronousFuture] in-frame, so the OFF/dormant path is byte-identical to today.
  @override
  Future<List<LipskeyCatalogProduct>> search(
    String query, {
    int limit = 20,
    Cursor? after,
  }) {
    final index = _index;
    // OFF / unwired (the shipped default) → the verbatim Layer-A scan, synchronously.
    if (index == null) return _layerA(query, limit);
    return _serverSearch(index, query, limit);
  }

  /// The token-narrow + fuzzy re-rank body. Any degrade path routes back to
  /// [_layerA] — the app never sees a blank page from a server hiccup.
  Future<List<LipskeyCatalogProduct>> _serverSearch(
    CatalogTokenIndex index,
    String query,
    int limit,
  ) async {
    final token = catalogNarrowToken(query);
    // Un-narrowable (empty / no word ≥ 3 chars) → can't form a superset filter.
    if (token == null) return _layerA(query, limit);
    try {
      final candidates =
          await index.candidatesForToken(token, limit: candidatePageSize);
      // The token indexed nothing → degrade rather than return blank.
      if (candidates.isEmpty) return _layerA(query, limit);
      // Re-rank the narrowed page with the SAME live ranker — answer-equivalent
      // (R1-7): the multi-word AND + proximity + cap, over fewer rows.
      return fuzzySearchProducts(query, products: candidates, limit: limit);
    } on Object catch (e) {
      // Offline / permission-denied / not-deployed → honest Layer-A, never blank.
      debugPrint('FirebaseSearchRepository: server search failed → Layer-A: $e');
      return _layerA(query, limit);
    }
  }

  /// The VERBATIM Layer-A fallback (`fuzzySearchProducts`, `fuzzy_search.dart:16`),
  /// resolved SYNCHRONOUSLY so the degraded path adds zero frame latency — the same
  /// answer, order and cap the ▦ search box computes today.
  Future<List<LipskeyCatalogProduct>> _layerA(String query, int limit) =>
      SynchronousFuture<List<LipskeyCatalogProduct>>(
        fuzzySearchProducts(query, limit: limit),
      );
}
