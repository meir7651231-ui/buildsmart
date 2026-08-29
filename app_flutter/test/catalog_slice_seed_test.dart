// C1.2 — MIGRATION of the thin slice (SPEC-catalog-to-server).
//
// Proves the 20 owner-approved SKUs seed into the `catalogProducts` server store via
// the EXISTING Step-61 importer (`seedC1Slice` → `seedCatalog`), that each doc is
// `toDoc`-shaped (16 fields · `active` stamped · NO price — R1-6), and that every doc
// ROUND-TRIPS field-for-field back to its `LipskeyCatalogProduct` via `fromDoc` (the
// contract the paged browse + engines rely on).
//
// NO Firebase / no fake_cloud_firestore: the staging seam ([CatalogSeedSink]) is
// driven by the SAME hand-rolled `_FakeSeedSink` (in-memory maps) as
// `catalog_seed_test.dart`. Decision 1-A: the C1 proof is `flutter test`-backed; the
// real-cloud seed (1-B) calls the same `seedC1Slice` with the live sink.

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/data/lipskey_verified_connections.dart'
    show kVerifiedSpecs;
import 'package:buildsmart/data/repositories/authored_products_firebase.dart';
import 'package:buildsmart/data/repositories/catalog_slice.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteDoc;
import 'package:flutter/foundation.dart' show listEquals, mapEquals;
import 'package:flutter_test/flutter_test.dart';

/// Hand-rolled fake [CatalogSeedSink] — three in-memory maps mirroring the live
/// `catalogProducts`, the `catalogPending/{batchId}` meta, and its staged items.
/// [set*] MERGE (Firestore `SetOptions(merge:true)`). Identical strategy to
/// `catalog_seed_test.dart` (the project's Firebase-free seed fake).
class _FakeSeedSink implements CatalogSeedSink {
  final Map<String, Map<String, dynamic>> live = {};
  final Map<String, Map<String, dynamic>> meta = {};
  final Map<String, Map<String, Map<String, dynamic>>> items = {};
  int stageCalls = 0;
  int liveWrites = 0;

  @override
  Future<void> stagePending(
      String batchId, String sku, Map<String, dynamic> data) async {
    stageCalls++;
    final batch = items[batchId] ??= {};
    batch[sku] = <String, dynamic>{...?batch[sku], ...data};
  }

  @override
  Future<RemoteDoc?> pendingMeta(String batchId) async {
    final m = meta[batchId];
    return m == null ? null : RemoteDoc(batchId, m);
  }

  @override
  Future<void> setPendingMeta(String batchId, Map<String, dynamic> data) async {
    meta[batchId] = <String, dynamic>{...?meta[batchId], ...data};
  }

  @override
  Future<List<RemoteDoc>> pendingItems(String batchId) async {
    final batch = items[batchId] ?? const {};
    return [for (final e in batch.entries) RemoteDoc(e.key, e.value)];
  }

  @override
  Future<void> setLive(String sku, Map<String, dynamic> data) async {
    liveWrites++;
    live[sku] = <String, dynamic>{...?live[sku], ...data};
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('C1 slice — definition (C1.1)', () {
    test('resolves EXACTLY the 20 approved SKUs, in order, no missing', () {
      final ps = c1SliceProducts();
      expect(ps, hasLength(20));
      expect(ps.map((p) => p.sku).toList(), kC1SliceSkus);
      expect(kC1SliceSkus.toSet(), hasLength(20), reason: 'no duplicate SKUs');
    });

    test('118220 is the complex manifold and carries a VerifiedSpec', () {
      final m = c1SliceProducts().firstWhere((p) => p.sku == '118220');
      expect(m.nameHe, contains('מסעף'));
      expect(kVerifiedSpecs.containsKey('118220'), isTrue);
    });

    test('diversity (owner criteria): >=5 categories, >=2 multi-image, spec + non-spec',
        () {
      final ps = c1SliceProducts();
      expect(ps.map((p) => p.categoryHe).toSet().length,
          greaterThanOrEqualTo(5));
      expect(ps.where((p) => p.imageAssets.length >= 2).length,
          greaterThanOrEqualTo(2),
          reason: 'the pager needs >=2 multi-image products');
      final withSpec = ps.where((p) => kVerifiedSpecs.containsKey(p.sku)).length;
      expect(withSpec, greaterThanOrEqualTo(1), reason: 'piping WITH VerifiedSpec');
      expect(withSpec, lessThan(20), reason: 'and some non-piping (no spec)');
    });
  });

  group('C1.2 migration — seed the slice into catalogProducts (fake sink)', () {
    test('seedC1Slice(live:false) stages → flips all 20 to the live collection',
        () async {
      final sink = _FakeSeedSink();
      final repo = FirebaseAuthoredProductsRepository(seedSink: sink);

      final outcome = await seedC1Slice(repo, live: false);

      expect(outcome.status, SeedStatus.flipped);
      expect(outcome.count, 20);
      expect(sink.live.keys.toSet(), kC1SliceSkus.toSet());
      expect(sink.meta[kC1SliceBatch]!['complete'], isTrue);
    });

    test('each live doc is toDoc-shaped: active:true, NO price (R1-6), dims preserved',
        () async {
      final sink = _FakeSeedSink();
      final repo = FirebaseAuthoredProductsRepository(seedSink: sink);
      await seedC1Slice(repo, live: false);

      final m = sink.live['118220']!;
      expect(m['sku'], '118220');
      expect(m['nameHe'], contains('מסעף'));
      expect(m['categoryHe'], 'מסעפים וחיבורי אסלה');
      expect(m['brand'], 'ליפסקי');
      expect(m['dims'], isA<Map<String, dynamic>>());

      for (final d in sink.live.values) {
        expect(d['active'], isTrue, reason: 'browse filters active==true');
        expect(d.containsKey('price'), isFalse,
            reason: 'R1-6: a catalog doc NEVER carries price');
      }
    });

    test('round-trip: fromDoc(seeded doc) reproduces every product field-for-field',
        () async {
      final sink = _FakeSeedSink();
      final repo = FirebaseAuthoredProductsRepository(seedSink: sink);
      await seedC1Slice(repo, live: false);

      final original = {for (final p in c1SliceProducts()) p.sku: p};
      for (final sku in kC1SliceSkus) {
        final back = repo.fromDoc(RemoteDoc(sku, sink.live[sku]!));
        _expectSameProduct(back, original[sku]!, sku);
      }
    });

    test('idempotent: a second seed re-flips the SAME 20 (never 40)', () async {
      final sink = _FakeSeedSink();
      final repo = FirebaseAuthoredProductsRepository(seedSink: sink);
      await seedC1Slice(repo, live: false);
      await seedC1Slice(repo, live: false);
      expect(sink.live, hasLength(20));
      expect(sink.stageCalls, 20, reason: 'staged once, not re-staged on re-run');
    });

    test('honest-empty gate holds for the slice (live && !seedFresh → skipped)',
        () async {
      final sink = _FakeSeedSink();
      final repo = FirebaseAuthoredProductsRepository(seedSink: sink);
      final outcome = await seedC1Slice(repo, live: true, seedFresh: false);
      expect(outcome.status, SeedStatus.skipped);
      expect(sink.live, isEmpty);
    });
  });
}

void _expectSameProduct(
    LipskeyCatalogProduct a, LipskeyCatalogProduct b, String ctx) {
  expect(a.sku, b.sku, reason: '$ctx sku');
  expect(a.nameHe, b.nameHe, reason: '$ctx nameHe');
  expect(a.nameEn, b.nameEn, reason: '$ctx nameEn');
  expect(a.color, b.color, reason: '$ctx color');
  expect(a.qtyPack, b.qtyPack, reason: '$ctx qtyPack');
  expect(a.qtyPallet, b.qtyPallet, reason: '$ctx qtyPallet');
  expect(a.categoryHe, b.categoryHe, reason: '$ctx categoryHe');
  expect(a.categoryEn, b.categoryEn, reason: '$ctx categoryEn');
  expect(a.categoryEmoji, b.categoryEmoji, reason: '$ctx categoryEmoji');
  expect(a.page, b.page, reason: '$ctx page');
  expect(mapEquals(a.dims, b.dims), isTrue, reason: '$ctx dims');
  expect(a.imageFile, b.imageFile, reason: '$ctx imageFile');
  expect(listEquals(a.imageFiles, b.imageFiles), isTrue, reason: '$ctx imageFiles');
  expect(a.specImageFile, b.specImageFile, reason: '$ctx specImageFile');
  expect(listEquals(a.specImageFiles, b.specImageFiles), isTrue,
      reason: '$ctx specImageFiles');
  expect(a.brand, b.brand, reason: '$ctx brand');
}
