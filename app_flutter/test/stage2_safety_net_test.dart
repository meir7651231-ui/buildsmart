// STAGE-2 · iron-rule #3 — "לא מבריק": runtime-broken data falls to the
// safety net (server → cache → bundled), never to a blank screen
// (DIRECTIVE-buildsmart-clean.md §2.3).
//
// Firebase-free. Reuses the catalog_sync_test harness idiom (fake KV +
// counting backend closures over the REAL toDoc/fromDoc mappers) and the
// standard widget-test asset-failure mechanism for the image fallback.
//
// Covers ONLY the stage-2 gaps (G1 corrupt-cache degrade, G3 image default
// errorBuilder); the rest of the chain is already pinned elsewhere
// (catalog_fallback_test C5.5 · firestore_cached_repo_test per-doc/stream-
// error · offline_order_queue_test corrupt-drop · orders_engine_test
// corrupt-payload→seed).

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/data/product_images.dart';
import 'package:buildsmart/data/repositories/authored_products_firebase.dart'
    show FirebaseAuthoredProductsRepository;
import 'package:buildsmart/data/repositories/catalog_slice.dart';
import 'package:buildsmart/data/repositories/catalog_sync.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeKv implements CatalogKvStore {
  final Map<String, String> m = {};

  @override
  String? read(String key) => m[key];

  @override
  Future<void> write(String key, String value) async {
    m[key] = value;
  }
}

/// The catalog_sync_test backend idiom — a mutable version + fetch counter +
/// a gate factory over one persistent KV.
class _Backend {
  _Backend(this.kv);
  final _FakeKv kv;
  final FirebaseAuthoredProductsRepository repo =
      FirebaseAuthoredProductsRepository();

  String version = 'v1';
  int catalogFetches = 0;
  bool online = true;

  Future<String> _readVersion() async {
    if (!online) throw StateError('offline');
    return version;
  }

  Future<List<LipskeyCatalogProduct>> _fetchAll() async {
    if (!online) throw StateError('offline');
    catalogFetches++;
    return c1SliceProducts();
  }

  CatalogSyncGate openGate({List<LipskeyCatalogProduct> Function()? bundled}) =>
      CatalogSyncGate(
        kv: kv,
        readServerVersion: _readVersion,
        fetchAll: _fetchAll,
        toDoc: repo.toDoc,
        fromDoc: repo.fromDoc,
        bundledFallback: bundled,
      );
}

void main() {
  group('G1 · CatalogSyncGate — a CORRUPT persisted cache degrades, never '
      'crashes (C5.5)', () {
    test('corrupt cache + server DOWN → bundled fallback (not a decode throw)',
        () async {
      final b = _Backend(_FakeKv());
      await b.openGate().open(); // warm the cache online
      expect(b.catalogFetches, 1);

      // Corrupt the persisted blob in place, then go offline.
      b.kv.m[CatalogSyncGate.kItemsKey] = '{corrupt[';
      b.online = false;

      final bundled = c1SliceProducts();
      final items = await b.openGate(bundled: () => bundled).open();
      expect(items, hasLength(20),
          reason: 'corrupt cache + offline → the bundled catalog, no crash');
      expect(b.catalogFetches, 1, reason: 'offline — no network hit');
    });

    test('corrupt cache + server UP → exactly one re-sync, self-healed cache',
        () async {
      final b = _Backend(_FakeKv());
      await b.openGate().open(); // warm (v1)
      expect(b.catalogFetches, 1);

      // Corrupt the blob; the server version is UNCHANGED (v1), so pre-fix the
      // gate would trust the version match and throw on decode.
      b.kv.m[CatalogSyncGate.kItemsKey] = '{corrupt[';

      final g = b.openGate();
      final items = await g.open();
      expect(items, hasLength(20));
      expect(g.fetchAllCalls, 1,
          reason: 'corrupt cache = cache MISS → one re-sync');
      expect(b.catalogFetches, 2);

      // Self-healed: the re-sync overwrote the corrupt bytes — a fresh open
      // serves the cache again with zero fetches.
      final g2 = b.openGate();
      await g2.open();
      expect(g2.fetchAllCalls, 0, reason: 'cache healthy again');
      expect(b.catalogFetches, 2);
    });
  });

  group('G3 · productImage — a failed load NEVER surfaces as an error', () {
    // Deterministic (no asset-load timing): assert the DEFAULT errorBuilder is
    // actually wired onto the Image when the caller passes none, and that it
    // renders the silent fallback. (A timing-based "no exception" variant
    // stayed green under mutation — this form goes RED when the default is
    // removed; proven via mutation-verify.)
    testWidgets('call-site with NO errorBuilder gets the silent default',
        (t) async {
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: productImage('assets/definitely-missing.png',
                width: 40, height: 40),
          ),
        ),
      );

      final img = t.widget<Image>(find.byType(Image));
      expect(img.errorBuilder, isNotNull,
          reason: 'stage-2 default: a failed load must be consumed, '
              'never surfaced as FlutterError noise');

      // The default builder renders the silent fallback (shrunk SizedBox).
      final ctx = t.element(find.byType(Image));
      final fallback = img.errorBuilder!(ctx, StateError('boom'), null);
      expect(fallback, isA<SizedBox>());
      final box = fallback as SizedBox;
      expect(box.width, 0.0);
      expect(box.height, 0.0);
    });
  });
}
