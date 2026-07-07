// ─────────────────────────────────────────────────────────────────────────────
// FirebaseSearchRepository — the Layer-B (server) implementation of
// [SearchRepository]. Pillar 5 · Step 62 SKELETON — DORMANT until the flags flip,
// its real body lands in step 63. A DROP-IN for [LocalSearchRepository]: the
// eventual consumers + the provider are unchanged — only which class
// `searchRepositoryProvider` returns changes (see the switch in `search_local.dart`).
//
// WHY THIS FILE IS A SKELETON THAT DELEGATES TO LAYER-A (not a Firestore query
// yet): step 62's job is only to establish the SEAM + the provider switch so the
// server search can slot in with a pure body-swap. The server contract itself is
// step 63: an `onCatalogProductWrite` Admin-SDK indexer derives `nameTokens` from
// `nameHe` ONLY (parity with the live `fuzzySearchProducts`, R1-7), and [search]
// then filters the rarest token (`catalogProducts.where('nameTokens',
// arrayContains: rarest)`) over the neutral PAGED authored-catalog seam
// ([AuthoredProductsSource]/[PagedQuery], steps 53/60) and RE-RANKS that small
// candidate page with the SAME `fuzzySearchProducts(query, products: candidates)`
// — an ANSWER-EQUIVALENT top-N, never a byte-identical ranking claim.
//
// UNTIL then this skeleton degrades to the VERBATIM Layer-A scan
// (`fuzzySearchProducts`, `fuzzy_search.dart:16`): that is exactly the step-63 DoD
// "`CATALOG_SERVER_SEARCH` OFF → Layer-A" contract, so a premature flag-flip yields
// HONEST results (the proven local ranking), never a blank/empty page (the R2-7
// "never blank" spirit). It is never actually reached on a shipped build: the
// provider returns this ONLY when [useCatalogServerSearch] is true
// (`kCatalogServerSearch && useFirebaseBackend`), both OFF by default.
//
// FIREBASE-FREE by construction (step 62): this skeleton imports NO
// `cloud_firestore` — step 63 reaches the collection through the NEUTRAL paged
// seam (already Firebase-free), so the live handle stays behind the one real
// adapter (`authored_products_firebase.dart`), exactly as the base fleet keeps it.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/fuzzy_search.dart' show fuzzySearchProducts;
import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/data/paged_query.dart' show Cursor;
import 'package:buildsmart/data/repositories/search_repository.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;

/// The Firestore-backed (Layer-B) implementation of [SearchRepository]. STEP 62
/// SKELETON: it holds no server query yet — step 63 replaces [search]'s body with
/// the token-narrow + candidate re-rank described in the header. Until then it
/// delegates to the VERBATIM Layer-A `fuzzySearchProducts` scan (honest results,
/// never blank), matching the step-63 "OFF → Layer-A" degradation contract.
class FirebaseSearchRepository implements SearchRepository {
  const FirebaseSearchRepository();

  /// STEP 62 SKELETON body — the VERBATIM Layer-A fallback (`fuzzySearchProducts`),
  /// resolved SYNCHRONOUSLY. [after] is accepted for the eventual paged Layer-B
  /// (step 63) but ignored here (the local scan is single-page). Step 63 swaps this
  /// for: fetch the rarest-`nameTokens` candidate page over the neutral paged seam,
  /// then `fuzzySearchProducts(query, products: candidates)` for the answer-equivalent
  /// top-N (R1-7).
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
