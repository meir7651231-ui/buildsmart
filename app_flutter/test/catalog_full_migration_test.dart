// C2.1 — FULL catalog migration (SPEC-catalog-to-server).
//
// Proves the WHOLE bundled catalog seeds into `catalogProducts` via the same Step-61
// importer used for the slice — with a COUNT-VERIFY (one live doc per distinct SKU,
// none lost or duplicated), each doc `toDoc`-shaped (active · no price · R1-6), and
// the brand mix intact. Fake sink — no Firebase (decision 1-A).

import 'package:buildsmart/data/polyroll_catalog.dart' show kCatalogProducts;
import 'package:buildsmart/data/repositories/authored_products_firebase.dart';
import 'package:buildsmart/data/repositories/catalog_migration.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteDoc;
import 'package:flutter_test/flutter_test.dart';

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

  final distinctSkus = kCatalogProducts.map((p) => p.sku).toSet();

  test('C2.1 — the whole catalog seeds to catalogProducts, COUNT-VERIFY', () async {
    final sink = _FakeSeedSink();
    final repo = FirebaseAuthoredProductsRepository(seedSink: sink);

    final outcome = await seedFullCatalog(repo, live: false);

    expect(outcome.status, SeedStatus.flipped);
    // COUNT-VERIFY: one live doc per DISTINCT sku — none lost, none duplicated.
    expect(sink.live.length, distinctSkus.length);
    expect(sink.live.keys.toSet(), distinctSkus);
    expect(outcome.count, distinctSkus.length);
    // Sanity: the catalog is the full union, not the 20-slice.
    expect(distinctSkus.length, greaterThan(1500),
        reason: 'the full catalog (~1,879), not the thin slice');
  });

  test('C2.1 — every live doc is toDoc-shaped (active · NO price) + brands intact',
      () async {
    final sink = _FakeSeedSink();
    final repo = FirebaseAuthoredProductsRepository(seedSink: sink);
    await seedFullCatalog(repo, live: false);

    for (final d in sink.live.values) {
      expect(d['active'], isTrue);
      expect(d.containsKey('price'), isFalse, reason: 'R1-6 at full scale too');
      expect(d['sku'] as String?, isNotEmpty);
    }

    // The brand mix survives (Lipskey / Polyroll / Huliot / hot-water).
    final brands = sink.live.values.map((d) => d['brand'] as String?).toSet();
    expect(brands.length, greaterThanOrEqualTo(2),
        reason: 'multiple supplier brands in the union');
  });

  test('C2.1 — SKU is the doc-id ⇒ a re-run is idempotent (no duplication)',
      () async {
    final sink = _FakeSeedSink();
    final repo = FirebaseAuthoredProductsRepository(seedSink: sink);
    await seedFullCatalog(repo, live: false);
    final firstCount = sink.live.length;
    await seedFullCatalog(repo, live: false); // re-run: re-flip only
    expect(sink.live.length, firstCount, reason: 'idempotent — never doubles');
    expect(sink.stageCalls, distinctSkus.length,
        reason: 'staged once, not re-staged');
  });
}
