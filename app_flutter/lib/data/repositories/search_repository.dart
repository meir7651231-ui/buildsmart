// ─────────────────────────────────────────────────────────────────────────────
// SearchRepository — the read surface for CATALOG SEARCH (the deterministic
// name-scan behind the ▦ search box / the AI finder's literal-first tier).
// Pillar 5 · Step 62.
//
// SERVER-READY SEAM (the proven repo-pair shape — mirrors [CatalogRepository] /
// [StudioConfigRepository]). This is the ABSTRACT interface only; the const
// local impl ([LocalSearchRepository], `search_local.dart`) and the Firestore
// skeleton ([FirebaseSearchRepository], `search_firebase.dart`) live beside it.
// When search moves to the paged server token-index (step 63) the ONLY thing
// that swaps is the implementation behind `searchRepositoryProvider` — the
// eventual consumers (`catalog_screen.dart` / `ai_finder_screen.dart`) stay
// unchanged (the `catalog_repository.dart:8` swap-implementation-only promise).
//
// THE TWO LAYERS (the plan's Layer-A / Layer-B):
//   • Layer-A (LOCAL, the OFF default) wraps today's `fuzzySearchProducts`
//     (`fuzzy_search.dart:16`) VERBATIM — same `nameHe`-only scan, same ranking,
//     same page. It returns a [SynchronousFuture] so the offline path resolves in
//     the SAME frame — byte-identical to today, zero added latency.
//   • Layer-B (SERVER, step 63) narrows candidates by the rarest `nameTokens`
//     (`arrayContains`) over the paged authored-catalog seam, then re-ranks that
//     small page with the SAME `fuzzySearchProducts` — an ANSWER-EQUIVALENT top-N
//     (R1-7), never a byte-identical ranking claim.
//
// ASYNC-BY-DESIGN (the drop-in over an async backend): the signature is a
// `Future` so Layer-B can page a remote index, but Layer-A resolves it
// SYNCHRONOUSLY ([SynchronousFuture]) so today's in-frame search is unchanged
// (the §3 trap — a naive `Future` would add a frame delay to the sync path).
//
// FIREBASE-FREE by construction: this file imports NO `cloud_firestore`. The
// [Cursor] it speaks (from `paged_query.dart`) is the NEUTRAL pagination
// position (id + sort value), never a `DocumentSnapshot` — so this seam and the
// tests that drive it need no Firebase to compile.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/data/paged_query.dart' show Cursor;

/// Server-ready contract over catalog search. The current backing is the const
/// in-memory `fuzzySearchProducts` scan ([LocalSearchRepository]); the paged
/// server token-index (step 63) swaps in behind `searchRepositoryProvider`.
///
/// The interface is a drop-in over an async backend — exactly like the other
/// repo-pairs — so a consumer awaits it once and never learns which layer served
/// it. `implements`-ing classes re-declare [search] (a Dart `implements` does not
/// inherit bodies; see the same note on `catalog_local.dart`).
// A deliberate one-member seam — a search repo answers exactly one question.
// ignore: one_member_abstracts
abstract class SearchRepository {
  /// The top matches for [query], ranked best-first. Layer-A (local) scans the
  /// bundled catalog with `fuzzySearchProducts` and resolves SYNCHRONOUSLY (same
  /// frame — zero latency); Layer-B (server, step 63) resumes AFTER [after] (a
  /// neutral [Cursor], null = the first page) and re-ranks the token-narrowed
  /// candidate page. [limit] caps the returned matches (default 20 — the same
  /// default as `fuzzySearchProducts`, so `search(q)` ≡ `fuzzySearchProducts(q)`;
  /// the ▦ call-site passes `limit: 40`, `catalog_screen.dart:364`). An empty /
  /// whitespace query yields an empty result (the `fuzzySearchProducts` contract).
  Future<List<LipskeyCatalogProduct>> search(
    String query, {
    int limit = 20,
    Cursor? after,
  });
}
