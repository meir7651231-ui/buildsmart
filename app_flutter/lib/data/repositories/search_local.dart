// ─────────────────────────────────────────────────────────────────────────────
// LocalSearchRepository — the Layer-A (const/in-memory) implementation of
// [SearchRepository]. Pillar 5 · Step 62. It is the OFF default: it wraps today's
// `fuzzySearchProducts` (`fuzzy_search.dart:16`) VERBATIM — the SAME `nameHe`
// scan, the SAME ranking, the SAME page — and returns it in a [SynchronousFuture]
// so the offline search path resolves in the SAME frame (zero added latency, the
// §3 trap avoided). Every read is therefore byte-for-byte what the ▦ search box /
// the finder's literal tier compute today.
//
// PURE + const — no [Ref], no Firebase, no `cloud_firestore`: the whole answer is
// the pure `fuzzySearchProducts` scan over the bundled `kCatalogProducts`, so this
// file (and the app path that returns it) need no backend to compile or run. If a
// later phase shrinks the bundled catalog to a starter set, the local layer keeps
// searching whatever bundle remains (offline stays non-empty) — `fuzzySearchProducts`
// owns that default source, so nothing here changes.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/fuzzy_search.dart' show fuzzySearchProducts;
import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/data/paged_query.dart' show Cursor;
import 'package:buildsmart/data/repositories/backend.dart'
    show useCatalogServerSearch;
import 'package:buildsmart/data/repositories/search_firebase.dart';
import 'package:buildsmart/data/repositories/search_repository.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The local (const-backed) implementation of [SearchRepository]. [search]
/// forwards to `fuzzySearchProducts` VERBATIM and wraps the result in a
/// [SynchronousFuture], so it resolves in the same frame the caller asks — the
/// Layer-A path is byte-identical to today. A future server impl swaps in behind
/// the same provider.
class LocalSearchRepository implements SearchRepository {
  const LocalSearchRepository();

  /// Layer-A search: the VERBATIM `fuzzySearchProducts` scan (`fuzzy_search.dart:16`)
  /// over the bundled catalog, resolved SYNCHRONOUSLY. [after] is ignored — the
  /// local layer is single-page (the whole ranked list up to [limit]); paging is a
  /// Layer-B (step 63) concern. [SynchronousFuture] keeps the OFF path frame-perfect
  /// (the same "born non-empty / no frame delay" spirit as `LocalPagedSource`).
  @override
  Future<List<LipskeyCatalogProduct>> search(
    String query, {
    int limit = 20,
    Cursor? after,
  }) =>
      SynchronousFuture<List<LipskeyCatalogProduct>>(
        fuzzySearchProducts(query, limit: limit),
      );
}

/// The search repository provider — the server-ready seam the search box / finder
/// eventually read through, and the paged server token-index (step 63) swaps in
/// behind. DORMANT (step 62): the `_firebase` branch activates ONLY when
/// server-search is flagged ON *and* the backend is live
/// ([useCatalogServerSearch] = `kCatalogServerSearch && useFirebaseBackend`); with
/// it OFF (the default) it returns the const Layer-A local impl — the verbatim
/// `fuzzySearchProducts` scan — so the build is BYTE-IDENTICAL to today. A `Provider`
/// is lazy: until a consumer reads it, it is never even constructed. Mirrors
/// `catalogRepositoryProvider` (`catalog_local.dart`) / `studioConfigRepositoryProvider`
/// (`studio_config_local.dart`) with the extra server-search flag gate.
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  if (useCatalogServerSearch) return const FirebaseSearchRepository();
  return const LocalSearchRepository();
});
