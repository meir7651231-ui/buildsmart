// C2.3 — RECIPES migration (SPEC-catalog-to-server).
//
// Proves the work-recipes seed to `recipes/{key}`, that a recipe round-trips
// STRUCTURE-for-structure (price intentionally omitted — R1-6 / C3.5), and — the DoD
// — that the SKU-JOIN works: every brand/accessory sku on a recipe resolves to a real
// catalog product. Fake sink — no Firebase.

import 'package:buildsmart/data/polyroll_catalog.dart' show kCatalogProducts;
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteDoc;
import 'package:buildsmart/data/repositories/recipe_seed.dart';
import 'package:buildsmart/data/smart_tree.dart'
    show SmartProduct, kSmartProducts;
import 'package:flutter_test/flutter_test.dart';

class _FakeDocSink {
  final Map<String, Map<String, dynamic>> docs = {};
  Future<void> call(String id, Map<String, dynamic> data) async {
    docs[id] = <String, dynamic>{...?docs[id], ...data};
  }
}

void main() {
  test('C2.3 — all recipes seed to recipes/{key}', () async {
    final sink = _FakeDocSink();
    final n = await seedAllRecipes(sink.call);

    expect(n, kSmartProducts.length);
    expect(sink.docs.length, kSmartProducts.length);
    expect(sink.docs.keys.toSet(), kSmartProducts.map((r) => r.key).toSet());
    expect(n, greaterThan(50), reason: 'the full recipe set (~83)');
  });

  test('C2.3 — SKU-JOIN: every brand/acc sku resolves to a catalog product', () {
    final catalogSkus = kCatalogProducts.map((p) => p.sku).toSet();
    var joined = 0;
    for (final r in kSmartProducts) {
      for (final b in r.brands) {
        if (b.sku != null) {
          expect(catalogSkus, contains(b.sku),
              reason: 'recipe ${r.key} brand sku ${b.sku} must join the catalog');
          joined++;
        }
      }
      for (final a in r.acc) {
        if (a.sku != null) {
          expect(catalogSkus, contains(a.sku),
              reason: 'recipe ${r.key} acc sku ${a.sku} must join the catalog');
          joined++;
        }
      }
    }
    expect(joined, greaterThan(0), reason: 'recipes really carry sku-links');
  });

  test('C2.3 — recipe round-trips STRUCTURE (sku-links kept; price omitted)', () {
    for (final r in kSmartProducts) {
      final rt = recipeFromDoc(RemoteDoc(r.key, recipeToDoc(r)));
      _sameRecipe(rt, r);
    }
  });

  test('C2.3 — the recipe doc carries NO price (R1-6 → price lives in inventory)', () {
    final sample = recipeToDoc(kSmartProducts.first);
    for (final b in (sample['brands'] as List).cast<Map<String, dynamic>>()) {
      expect(b.containsKey('price'), isFalse);
    }
    for (final a in (sample['acc'] as List).cast<Map<String, dynamic>>()) {
      expect(a.containsKey('price'), isFalse);
    }
  });
}

void _sameRecipe(SmartProduct a, SmartProduct b) {
  expect(a.key, b.key, reason: 'key');
  expect(a.name, b.name, reason: '${b.key} name');
  expect(a.cat, b.cat, reason: '${b.key} cat');
  expect(a.diagramTitle, b.diagramTitle, reason: '${b.key} diagramTitle');

  expect(a.brands.length, b.brands.length, reason: '${b.key} #brands');
  for (var i = 0; i < b.brands.length; i++) {
    expect(a.brands[i].name, b.brands[i].name, reason: '${b.key} brand$i name');
    expect(a.brands[i].tag, b.brands[i].tag, reason: '${b.key} brand$i tag');
    expect(a.brands[i].rec, b.brands[i].rec, reason: '${b.key} brand$i rec');
    expect(a.brands[i].sku, b.brands[i].sku, reason: '${b.key} brand$i sku');
  }

  expect(a.acc.length, b.acc.length, reason: '${b.key} #acc');
  for (var i = 0; i < b.acc.length; i++) {
    expect(a.acc[i].name, b.acc[i].name, reason: '${b.key} acc$i name');
    expect(a.acc[i].why, b.acc[i].why, reason: '${b.key} acc$i why');
    expect(a.acc[i].must, b.acc[i].must, reason: '${b.key} acc$i must');
    expect(a.acc[i].sku, b.acc[i].sku, reason: '${b.key} acc$i sku');
  }

  expect(a.stages.length, b.stages.length, reason: '${b.key} #stages');
  for (var i = 0; i < b.stages.length; i++) {
    expect(a.stages[i].label, b.stages[i].label, reason: '${b.key} stage$i label');
    expect(a.stages[i].isFinal, b.stages[i].isFinal, reason: '${b.key} stage$i final');
    expect(a.stages[i].match, b.stages[i].match, reason: '${b.key} stage$i match');
  }
}
