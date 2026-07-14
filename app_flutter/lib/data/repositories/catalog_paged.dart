// ─────────────────────────────────────────────────────────────────────────────
// Catalog data-cache · PAGED browse + CATALOG_BASE_URL switch — Studio Pillar 5 ·
// Step 64. The DATA twin of `data/product_images.dart`: the same
// `<base>.isEmpty ? bundled : remote` shape the image path uses
// (`product_images.dart:39` `resolveProductImage`), lifted from IMAGE bytes to
// catalog DATA pages.
//
// ⚠️ S3.K RECONCILIATION (the detail predates this decision). The original step-64
// vision — "CATALOG_BASE_URL set → the WHOLE catalog pages from a CDN" — was
// SUPERSEDED by row S3.K: the STATIC 1,877-product catalog (`kCatalogProducts`) is
// bundled const Dart + R2-CDN images at ZERO DB cost and must NEVER route through
// Firestore (locked by `catalog_static_guard_test`). So the two branches of the
// switch here are:
//   • kCatalogBaseUrl EMPTY (the default / OFF) → the BUNDLED const catalog, served
//     as ONE synchronous page — byte-identical to today, zero DB, NO listener.
//   • kCatalogBaseUrl SET + backend live → the AUTHORED superset (the NEW products
//     the Studio trade-builder creates, held in `catalogProducts/{sku}`), browsed
//     by CURSOR PAGING via `FirebaseAuthoredProductsRepository.browse` (step 60) —
//     never a whole-collection `snapshots()` over 10K docs (the §1.6 memory/egress
//     trap). The bounded [CatalogPageCache] keeps only a few pages in memory.
//
// WHY THIS `catalog_*.dart` FILE IS ALLOWED (and is scanned green by
// `catalog_static_guard_test`): it imports NO `cloud_firestore` and constructs no
// base-cache adapter. The remote branch delegates to
// `FirebaseAuthoredProductsRepository`, which holds the NEUTRAL browse seam
// (`AuthoredProductsSource`) — the ONE file that may touch a live Firestore is the
// authored adapter, never this one. So the static-catalog zero-DB latch stays
// locked: this file couples to no DB handle.
//
// DORMANT / byte-identical when OFF: NOTHING wires these providers yet (the browse
// screen keeps its current const path), so the shipped build is byte-identical by
// NON-CONSUMPTION — exactly like `authored_products_firebase.dart`. When a consumer
// DOES read `catalogPagedBrowseProvider` with the flag OFF (the ship default) it
// gets the bundled const page — the same data the screen reads today. The paged
// branch activates only at the step-68 cutover (`kCatalogBaseUrl` + a live backend).
//
// Comment density/voice mirrors `product_images.dart` / `search_local.dart`.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:collection' show LinkedHashMap;

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/data/paged_query.dart' show Cursor, PagedResult;
import 'package:buildsmart/data/polyroll_catalog.dart' show kCatalogProducts;
import 'package:buildsmart/data/repositories/authored_products_firebase.dart'
    show FirebaseAuthoredProductsRepository;
import 'package:buildsmart/data/repositories/backend.dart'
    show kCatalogBaseUrl, useFirebaseBackend;
import 'package:flutter/foundation.dart' show SynchronousFuture, debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// True only when a server catalog base URL is configured AND the backend is live
/// — the browse twin of `useCatalogServerSearch` (`backend.dart:214`) and the data
/// twin of `resolveProductImage`'s `kImageBaseUrl.isEmpty` switch
/// (`product_images.dart:40`). Empty [kCatalogBaseUrl] (the default) ⇒ the bundled
/// const catalog, byte-identical + zero DB cost (S3.K); a non-empty value can't
/// activate offline / in tests, so the OFF path stays dormant.
bool get useServerCatalog =>
    kCatalogBaseUrl.isNotEmpty && useFirebaseBackend;

/// Bounded in-memory LRU of browse PAGES — the DATA twin of `product_images.dart`'s
/// bounded [CacheManager] (`product_images.dart:17`, LRU 700 / 60-day, "60k+
/// safe"). Only the recently-viewed pages are kept ([maxPages]); the least-recently
/// used is evicted, so a 10K-SKU authored catalog can never pile every page in
/// memory (§4 Memory — the step-64 memory-cap). Pure Dart, Firebase-free, so the
/// whole cache is unit-tested directly.
class CatalogPageCache {
  /// [maxPages] — how many browse pages are retained before the least-recently
  /// used is dropped. Small by design: only the pages near the viewport matter.
  CatalogPageCache({this.maxPages = _defaultMaxPages})
      : assert(maxPages > 0, 'a page cache must retain at least one page');

  /// A handful of pages (≈8 × 40 = 320 models) — bounded like the image cache.
  static const int _defaultMaxPages = 8;

  /// The page-retention cap (constructor arg): once a [put] would push [length]
  /// past this, the least-recently-used page(s) evict. Small by design.
  final int maxPages;

  /// The retained pages, keyed by their resume cursor id ([_keyFor]).
  /// [LinkedHashMap] preserves insertion order, so the eldest key is the LRU one.
  final LinkedHashMap<String, PagedResult<LipskeyCatalogProduct>> _pages =
      LinkedHashMap<String, PagedResult<LipskeyCatalogProduct>>();

  /// The number of pages currently retained (drives the memory-cap assertion).
  int get length => _pages.length;

  /// Whether a page for [key] is currently cached (does NOT mark it used).
  bool containsKey(String key) => _pages.containsKey(key);

  /// The cached page for [key], or null on a miss. A HIT marks the page as
  /// most-recently-used (remove + re-insert), so a page near the viewport isn't
  /// the one evicted next.
  PagedResult<LipskeyCatalogProduct>? get(String key) {
    final value = _pages.remove(key);
    if (value == null) return null;
    _pages[key] = value; // re-insert → most-recently-used
    return value;
  }

  /// Cache [value] under [key], evicting the least-recently-used page(s) once the
  /// cap is exceeded — so the retained set never grows past [maxPages].
  void put(String key, PagedResult<LipskeyCatalogProduct> value) {
    if (_pages.containsKey(key)) {
      _pages.remove(key); // drop the stale copy so the re-insert marks it MRU
    }
    _pages[key] = value;
    while (_pages.length > maxPages) {
      final eldest = _pages.keys.first; // insertion order → the LRU key
      _pages.remove(eldest);
    }
  }

  /// Drop every cached page (e.g. after a catalog version-bump invalidates them).
  void clear() => _pages.clear();
}

/// The app-wide default bounded page cache — the top-level twin of
/// `product_images.dart`'s `productImageCache` singleton (`product_images.dart:17`).
final CatalogPageCache catalogPageCache = CatalogPageCache();

/// The paged catalog BROWSE coordinator — the switch `product_images.dart` is the
/// twin of. One instance describes ONE browse source: either the bundled const
/// catalog (served as a single synchronous page) or the cursor-paged authored
/// superset (bounded-cached). A consumer calls [page] repeatedly, threading the
/// previous [PagedResult.cursor] into the next call until [PagedResult.hasMore] is
/// false (the sentinel-footer signal — twin of `capped`, the browse virtualization
/// in `catalog_screen.dart`).
class CatalogPagedBrowse {
  /// The BUNDLED path (empty CATALOG_BASE_URL / OFF): the whole const catalog is a
  /// single page. Byte-identical to today — zero DB, no network, no listener. The
  /// page is built ONCE (not per call), so [page] is a pure synchronous return.
  /// [bundled] defaults to the const [kCatalogProducts]; a test may pass a subset.
  CatalogPagedBrowse.bundled({List<LipskeyCatalogProduct>? bundled})
      : _authored = null,
        _cache = null,
        _bundledPage = PagedResult<LipskeyCatalogProduct>(
          items: List<LipskeyCatalogProduct>.unmodifiable(
            bundled ?? kCatalogProducts,
          ),
          cursor: null,
          hasMore: false,
        );

  /// The PAGED path (CATALOG_BASE_URL set + backend live): cursor pages over the
  /// authored superset via [authored] (`FirebaseAuthoredProductsRepository.browse`,
  /// step 60), each page retained in the bounded [cache]. NEVER a whole-collection
  /// listen (§1.6). [cache] defaults to the shared [catalogPageCache].
  CatalogPagedBrowse.paged(
    FirebaseAuthoredProductsRepository authored, {
    CatalogPageCache? cache,
  })  : _authored = authored,
        _cache = cache ?? catalogPageCache,
        _bundledPage = null;

  /// The authored-superset browse source (null ⇒ the bundled path).
  final FirebaseAuthoredProductsRepository? _authored;

  /// The bounded page cache (non-null ⇒ the paged path).
  final CatalogPageCache? _cache;

  /// The pre-built single page for the bundled path (non-null ⇒ the bundled path).
  final PagedResult<LipskeyCatalogProduct>? _bundledPage;

  /// The cache key for the FIRST page (no resume cursor). A real cursor's
  /// `lastDocId` is always a non-empty Firestore doc-id, so the empty string
  /// uniquely marks page one.
  static const String _firstPageKey = '';

  /// Whether this browse PAGES a remote source (true) or serves the bundled const
  /// catalog in one page (false) — the [useServerCatalog] switch resolved.
  bool get isPaged => _authored != null;

  /// Fetch one browse PAGE, resuming AFTER [after] (null = the first page).
  ///
  /// BUNDLED → the whole const catalog in ONE synchronous page (`hasMore:false`,
  /// no sentinel, no DB, no listener) — the [SynchronousFuture] keeps the OFF path
  /// frame-perfect, exactly like `LocalPagedSource` / the Layer-A search.
  ///
  /// PAGED → the authored cursor page (≤40, the [PagedQuery] cap). A page already
  /// fetched is returned SYNCHRONOUSLY from the bounded cache (a re-scroll pays no
  /// egress — the §6 saving); a miss fetches via [FirebaseAuthoredProductsRepository.browse]
  /// (a bounded PULL, never `snapshots()`) and caches the result.
  Future<PagedResult<LipskeyCatalogProduct>> page({Cursor? after}) {
    final bundledPage = _bundledPage;
    if (bundledPage != null) {
      return SynchronousFuture<PagedResult<LipskeyCatalogProduct>>(bundledPage);
    }
    final authored = _authored!;
    final cache = _cache!;
    final key = after?.lastDocId ?? _firstPageKey;
    final cached = cache.get(key);
    if (cached != null) {
      return SynchronousFuture<PagedResult<LipskeyCatalogProduct>>(cached);
    }
    return authored.browse(after: after).then((result) {
      cache.put(key, result);
      return result;
    }).catchError((Object e, StackTrace st) {
      // GO-LIVE SAFETY (C5.5) — a server read must NEVER show a broken/empty catalog.
      // On failure, fall back to the bundled const catalog: the FIRST page serves the
      // whole bundled catalog (browsing always works); a LATER page just stops paging
      // (empty terminal — no duplicates). The rollout can be turned off, but even ON a
      // transient Firestore blip degrades gracefully instead of blanking the catalog.
      debugPrint('CatalogPagedBrowse: server browse failed → bundled fallback: $e');
      return after == null
          ? PagedResult<LipskeyCatalogProduct>(
              items: List<LipskeyCatalogProduct>.unmodifiable(kCatalogProducts),
              cursor: null,
              hasMore: false,
            )
          : const PagedResult<LipskeyCatalogProduct>(
              items: <LipskeyCatalogProduct>[],
              cursor: null,
              hasMore: false,
            );
    });
  }
}

/// The paged catalog browse provider — the "new providers" step 64 adds, DORMANT
/// until a consumer reads it (a `Provider` is lazy: never constructed until first
/// read). The switch (the data twin of `resolveProductImage`):
///   • [useServerCatalog] false — `kCatalogBaseUrl` empty and/or the backend not
///     live (the ship/test default) → the BUNDLED const catalog in one page:
///     byte-identical, zero DB, no listener.
///   • [useServerCatalog] true — `kCatalogBaseUrl` set + backend live → the PAGED
///     authored superset (cursor paging over `authored_products_firebase.dart`,
///     never a 10K listen), served through the shared bounded [catalogPageCache].
/// Mirrors `searchRepositoryProvider` (`search_local.dart:62`) /
/// `catalogRepositoryProvider` (`catalog_local.dart:179`) with the base-URL gate.
final catalogPagedBrowseProvider = Provider<CatalogPagedBrowse>((ref) {
  if (!useServerCatalog) return CatalogPagedBrowse.bundled();
  return CatalogPagedBrowse.paged(
    FirebaseAuthoredProductsRepository(),
    cache: catalogPageCache,
  );
});
