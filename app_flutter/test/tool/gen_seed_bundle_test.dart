// GO-LIVE tool — generate the FULL Firestore seed bundle (all 5 collections) that the
// seed-catalog CI workflow uploads. NOT a normal test: it writes a file, so it is a
// no-op unless GEN_SEED_BUNDLE=1 is in the environment (the full suite skips it).
//
//   GEN_SEED_BUNDLE=1 flutter test test/tool/gen_seed_bundle_test.dart
//
// It reuses the EXACT seed serializers (seedFullCatalog / seedAllVerifiedSpecs /
// seedAllRecipes + the store/inventory toDoc) via capturing sinks, so the bundle is
// byte-for-byte what the real seed would write. Output: scripts/seed/firestore_seed_full.json.

import 'dart:convert';
import 'dart:io';

import 'package:buildsmart/data/repositories/authored_products_firebase.dart';
import 'package:buildsmart/data/repositories/catalog_migration.dart';
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteDoc;
import 'package:buildsmart/data/repositories/recipe_seed.dart';
import 'package:buildsmart/data/repositories/store_inventory.dart';
import 'package:flutter_test/flutter_test.dart';

/// Captures the docs seedFullCatalog would write live (the `live` map = {sku: doc}).
class _CaptureSeedSink implements CatalogSeedSink {
  final Map<String, Map<String, dynamic>> live = {};
  final Map<String, Map<String, dynamic>> _meta = {};
  final Map<String, Map<String, Map<String, dynamic>>> _items = {};

  @override
  Future<void> stagePending(
      String batchId, String sku, Map<String, dynamic> data) async {
    final batch = _items[batchId] ??= {};
    batch[sku] = <String, dynamic>{...?batch[sku], ...data};
  }

  @override
  Future<RemoteDoc?> pendingMeta(String batchId) async {
    final m = _meta[batchId];
    return m == null ? null : RemoteDoc(batchId, m);
  }

  @override
  Future<void> setPendingMeta(String batchId, Map<String, dynamic> data) async {
    _meta[batchId] = <String, dynamic>{...?_meta[batchId], ...data};
  }

  @override
  Future<List<RemoteDoc>> pendingItems(String batchId) async {
    final batch = _items[batchId] ?? const {};
    return [for (final e in batch.entries) RemoteDoc(e.key, e.value)];
  }

  @override
  Future<void> setLive(String sku, Map<String, dynamic> data) async {
    live[sku] = <String, dynamic>{...?live[sku], ...data};
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('GO-LIVE — generate the full seed bundle → scripts/seed/firestore_seed_full.json',
      () async {
    if (Platform.environment['GEN_SEED_BUNDLE'] != '1') {
      markTestSkipped('set GEN_SEED_BUNDLE=1 to (re)generate the bundle');
      return;
    }

    // 1) catalogProducts — every bundled product, via seedFullCatalog's own writer.
    final catSink = _CaptureSeedSink();
    final repo = FirebaseAuthoredProductsRepository(seedSink: catSink);
    final outcome = await seedFullCatalog(repo, live: false);
    expect(outcome.status, SeedStatus.flipped);
    expect(catSink.live.length, greaterThan(1500));

    // 2) verified_specs — all specs (+ the runtime PPR ones folded in).
    final specs = <String, Map<String, dynamic>>{};
    await seedAllVerifiedSpecs((id, data) async {
      specs[id] = data;
    });
    expect(specs.length, greaterThan(800));

    // 3) recipes — every work-recipe (price stays null — R1-6).
    final recipes = <String, Map<String, dynamic>>{};
    await seedAllRecipes((id, data) async {
      recipes[id] = data;
    });
    expect(recipes, isNotEmpty);

    // 4) stores + 5) inventory — the demo store layer (price/stock live here).
    final stores = <String, Map<String, dynamic>>{
      for (final s in kC1Stores) s.id: s.toDoc(),
    };
    final inventory = <String, Map<String, dynamic>>{
      for (final it in c1Inventory()) it.docId: it.toDoc(),
    };

    final bundle = <String, Map<String, Map<String, dynamic>>>{
      'catalogProducts': catSink.live,
      'verified_specs': specs,
      'recipes': recipes,
      'stores': stores,
      'inventory': inventory,
    };

    final out = File('../scripts/seed/firestore_seed_full.json')
      ..writeAsStringSync(const JsonEncoder.withIndent('  ').convert(bundle));

    final total = bundle.values.fold<int>(0, (n, m) => n + m.length);
    stdout.writeln('WROTE ${out.path}: '
        'catalogProducts=${catSink.live.length} · verified_specs=${specs.length} · '
        'recipes=${recipes.length} · stores=${stores.length} · '
        'inventory=${inventory.length} · TOTAL=$total docs');
    expect(out.existsSync(), isTrue);
  });
}
