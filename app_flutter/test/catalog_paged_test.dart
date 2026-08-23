// Studio Pillar 5 · Step 64 — the paged catalog data-cache + CATALOG_BASE_URL
// switch (`lib/data/repositories/catalog_paged.dart`).
//
// Pins the step-64 contract (adapted to the current S3.K code — the "catalog"
// that PAGES is the AUTHORED superset; the STATIC 1,877-product catalog stays
// bundled, byte-identical, zero DB):
//   1. BUNDLED (empty CATALOG_BASE_URL / OFF) — the whole const catalog in ONE
//      SYNCHRONOUS page: `hasMore:false`, `cursor:null`, items == kCatalogProducts
//      (byte-identical, no DB, NO listener).
//   2. DORMANT — `catalogPagedBrowseProvider` defaults to the bundled path (the
//      base-URL flag is empty in tests), so the build is byte-identical to today.
//   3. PAGED (a fake authored source) — cursor PAGES: page 2 continues from page
//      1's cursor, a FULL page sets `hasMore:true` (the sentinel/`capped` footer
//      signal), the last partial page sets `hasMore:false`.
//   4. CACHE HIT — a re-browse of a fetched cursor is served SYNCHRONOUSLY from the
//      bounded cache and does NOT re-fetch (the egress saving).
//   5. MEMORY-CAP — [CatalogPageCache] is a bounded LRU: it never retains more than
//      `maxPages`, and it evicts the LEAST-recently-used page (§4 Memory).
//   6. NO LISTENER / FIREBASE-FREE — the new file imports no `cloud_firestore` and
//      calls no `snapshots(` in live code (browse is a bounded PULL, never a
//      whole-collection listen); [CatalogPagedBrowse.page] returns a `Future`.
//
// NO Firebase here: the authored browse seam ([AuthoredProductsSource]) is driven
// by a HAND-ROLLED fake (the `authored_products_firebase_test` / `paged_query_test`
// idiom — no fake_cloud_firestore, no new packages).

import 'dart:io';

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/data/paged_query.dart' show Cursor, PagedResult;
import 'package:buildsmart/data/polyroll_catalog.dart' show kCatalogProducts;
import 'package:buildsmart/data/repositories/authored_products_firebase.dart';
import 'package:buildsmart/data/repositories/catalog_paged.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteDoc;
import 'package:flutter/foundation.dart' show SynchronousFuture, listEquals;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A hand-rolled fake [AuthoredProductsSource]: an in-memory `sku → field-map`
/// store that SLICES paged reads by cursor (the `authored_products_firebase_test`
/// idiom). [pageCalls] counts every `page` fetch so the cache-hit test can prove a
/// re-browse pays no round-trip.
class _FakeAuthoredProductsSource implements AuthoredProductsSource {
  final Map<String, Map<String, dynamic>> docs = {};

  /// How many times [page] actually fetched (a cache hit must NOT increment this).
  int pageCalls = 0;

  /// Seed [n] active products `sku-0000..` with zero-padded `nameHe`, so their
  /// lexicographic (`nameHe`, id) order equals their index order.
  void seedProducts(int n) {
    for (var i = 0; i < n; i++) {
      final id = 'sku-${i.toString().padLeft(4, '0')}';
      docs[id] = <String, dynamic>{
        'sku': id,
        'nameHe': 'item ${i.toString().padLeft(4, '0')}',
        'active': true,
      };
    }
  }

  @override
  bool get isSinglePage => false;

  @override
  Future<List<RemoteDoc>> page({required int limit, Cursor? after}) async {
    pageCalls++;
    final live = docs.entries
        .where((e) => e.value['active'] != false)
        .toList()
      ..sort((a, b) {
        final an = (a.value['nameHe'] as String?) ?? a.key;
        final bn = (b.value['nameHe'] as String?) ?? b.key;
        final c = an.compareTo(bn);
        return c != 0 ? c : a.key.compareTo(b.key);
      });
    final start = after == null
        ? 0
        : live.indexWhere((e) => e.key == after.lastDocId) + 1;
    return live
        .skip(start)
        .take(limit)
        .map((e) => RemoteDoc(e.key, e.value))
        .toList(growable: false);
  }

  @override
  Future<RemoteDoc?> get(String sku) async {
    final data = docs[sku];
    return data == null ? null : RemoteDoc(sku, data);
  }

  @override
  Future<void> set(String sku, Map<String, dynamic> data) async {
    docs[sku] = <String, dynamic>{...?docs[sku], ...data};
  }

  @override
  Future<void> setPricing(
    String sku,
    String audience,
    Map<String, dynamic> data,
  ) async {}
}

/// A throwaway page for the cache unit tests (contents irrelevant).
PagedResult<LipskeyCatalogProduct> _emptyPage() =>
    const PagedResult<LipskeyCatalogProduct>(
      items: <LipskeyCatalogProduct>[],
      cursor: null,
      hasMore: false,
    );

/// True when [rawSource] has a live `import '…cloud_firestore…';` directive
/// (anchored to an import so a doc-comment mention can't count). Mirrors
/// `catalog_static_guard_test` / `search_repository_test`.
bool _importsFirestore(String rawSource) => RegExp(
      '''import\\s+['"][^'"]*cloud_firestore[^'"]*['"]''',
    ).hasMatch(rawSource);

/// Strip `//` and `/* */` comments so a live-code identifier scan ignores the
/// prose (this file's own header, the repo file's "never `snapshots()`" note).
/// Copied verbatim from `catalog_static_guard_test`.
String _stripComments(String src) {
  final noBlock = src.replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), ' ');
  final sb = StringBuffer();
  for (final line in noBlock.split('\n')) {
    final i = line.indexOf('//');
    sb.writeln(i >= 0 ? line.substring(0, i) : line);
  }
  return sb.toString();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CatalogPagedBrowse — BUNDLED (empty CATALOG_BASE_URL / OFF)', () {
    test('the whole const catalog is ONE synchronous page, byte-identical',
        () async {
      final browse = CatalogPagedBrowse.bundled();
      expect(browse.isPaged, isFalse);

      final future = browse.page();
      // Frame-perfect: the OFF path resolves in the same frame (no network / no DB).
      expect(
        future,
        isA<SynchronousFuture<PagedResult<LipskeyCatalogProduct>>>(),
        reason: 'the bundled path must resolve synchronously — zero added latency',
      );

      final page = await future;
      // Byte-identical: the SAME const rows, in the SAME order, as today's screen.
      expect(page.items.length, kCatalogProducts.length);
      expect(
        listEquals(page.items, kCatalogProducts),
        isTrue,
        reason: 'bundled browse must return kCatalogProducts verbatim (S3.K — the '
            'static catalog stays bundled, byte-identical)',
      );
      // A single page: no continuation, no sentinel footer, no next fetch.
      expect(page.hasMore, isFalse);
      expect(page.cursor, isNull);
    });

    test('page() is a Future (a bounded PULL) — never a Stream/listen', () {
      final browse = CatalogPagedBrowse.bundled();
      expect(
        browse.page(),
        isA<Future<PagedResult<LipskeyCatalogProduct>>>(),
        reason: 'browse is a one-shot pull, not a whole-collection listen',
      );
    });
  });

  group('catalogPagedBrowseProvider — dormant / byte-identical OFF', () {
    test('useServerCatalog is OFF with an empty base URL (test default)', () {
      expect(
        useServerCatalog,
        isFalse,
        reason: 'CATALOG_BASE_URL is empty + no live backend in tests → the '
            'bundled const catalog, zero DB',
      );
    });

    test('the provider defaults to the BUNDLED path', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final browse = container.read(catalogPagedBrowseProvider);
      expect(browse, isA<CatalogPagedBrowse>());
      expect(
        browse.isPaged,
        isFalse,
        reason: 'with the base-URL flag OFF the seam must serve the bundled '
            'const catalog (dormant / byte-identical)',
      );
      final page = await browse.page();
      expect(page.items.length, kCatalogProducts.length);
      expect(page.hasMore, isFalse);
    });
  });

  group('CatalogPagedBrowse — PAGED (fake authored source)', () {
    test('cursor PAGES: page 2 continues from page 1 cursor, hasMore drives the '
        'sentinel', () async {
      final source = _FakeAuthoredProductsSource()..seedProducts(100);
      final repo = FirebaseAuthoredProductsRepository(source: source);
      final browse = CatalogPagedBrowse.paged(repo, cache: CatalogPageCache());
      expect(browse.isPaged, isTrue);

      final p1 = await browse.page();
      expect(p1.items, hasLength(40));
      expect(p1.hasMore, isTrue, reason: 'a full page → the sentinel/capped footer');
      expect(p1.items.first.sku, 'sku-0000');
      expect(p1.items.last.sku, 'sku-0039');
      expect(p1.cursor, isNotNull);

      // Page 2 resumes AFTER the cursor — the next slice, never an offset re-scan.
      final p2 = await browse.page(after: p1.cursor);
      expect(p2.items, hasLength(40));
      expect(p2.items.first.sku, 'sku-0040');
      expect(p2.hasMore, isTrue);

      // Page 3 is the final partial page → no sentinel (hasMore false).
      final p3 = await browse.page(after: p2.cursor);
      expect(p3.items, hasLength(20));
      expect(p3.hasMore, isFalse);
      expect(p3.cursor, isNull);
    });

    test('a fetched page is served from cache SYNCHRONOUSLY — no re-fetch',
        () async {
      final source = _FakeAuthoredProductsSource()..seedProducts(50);
      final repo = FirebaseAuthoredProductsRepository(source: source);
      final browse = CatalogPagedBrowse.paged(repo, cache: CatalogPageCache());

      await browse.page(); // first page — a real fetch
      expect(source.pageCalls, 1);

      // Same cursor again → a cache HIT: synchronous, and no second fetch.
      final again = browse.page();
      expect(
        again,
        isA<SynchronousFuture<PagedResult<LipskeyCatalogProduct>>>(),
        reason: 'a cached page must resolve in-frame (egress saving)',
      );
      await again;
      expect(source.pageCalls, 1, reason: 'the cache hit must not re-fetch');
    });
  });

  group('CatalogPageCache — bounded LRU (memory-cap, §4)', () {
    test('never retains more than maxPages — evicts the eldest', () {
      final cache = CatalogPageCache(maxPages: 2)
        ..put('a', _emptyPage())
        ..put('b', _emptyPage())
        ..put('c', _emptyPage()); // 'a' is the eldest → evicted

      expect(cache.length, 2);
      expect(cache.containsKey('a'), isFalse);
      expect(cache.containsKey('b'), isTrue);
      expect(cache.containsKey('c'), isTrue);
    });

    test('a HIT marks a page most-recently-used (LRU, not FIFO)', () {
      final cache = CatalogPageCache(maxPages: 2)
        ..put('a', _emptyPage())
        ..put('b', _emptyPage());

      // Touch 'a' → it becomes MRU, so the next insert evicts 'b', not 'a'.
      expect(cache.get('a'), isNotNull);
      cache.put('c', _emptyPage());

      expect(cache.length, 2);
      expect(cache.containsKey('a'), isTrue, reason: 'recently used — kept');
      expect(cache.containsKey('b'), isFalse, reason: 'least-recently used — evicted');
      expect(cache.containsKey('c'), isTrue);
    });

    test('clear drops every cached page', () {
      final cache = CatalogPageCache()
        ..put('a', _emptyPage())
        ..put('b', _emptyPage());
      expect(cache.length, 2);
      cache.clear();
      expect(cache.length, 0);
    });
  });

  group('DoD — no listener, Firebase-free (S3.K zero-DB latch)', () {
    test('catalog_paged.dart imports no cloud_firestore and never listens', () {
      final f = File('lib/data/repositories/catalog_paged.dart');
      expect(f.existsSync(), isTrue);
      final raw = f.readAsStringSync();

      expect(
        _importsFirestore(raw),
        isFalse,
        reason: 'the paged browse must stay Firebase-free — the live handle stays '
            'behind the one authored adapter, so this file cannot open a listener',
      );
      // No whole-collection listen in LIVE code (comments may mention it).
      expect(
        _stripComments(raw).contains('snapshots('),
        isFalse,
        reason: 'browse is a bounded PULL (paged get), never a snapshots() listen',
      );
    });

    test('sanity — the import detector FIRES on the real authored adapter', () {
      final adapter =
          File('lib/data/repositories/authored_products_firebase.dart');
      if (!adapter.existsSync()) {
        markTestSkipped('authored adapter absent — sanity check moot');
        return;
      }
      expect(
        _importsFirestore(adapter.readAsStringSync()),
        isTrue,
        reason: 'the detector must match the file that really imports Firestore, '
            'else the check above could pass vacuously',
      );
    });
  });
}
