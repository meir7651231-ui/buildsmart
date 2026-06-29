// Pins the plumbing seed builder (step 36): it is DETERMINISTIC (two builds are
// equal — the runtime-builder equivalent of "two script runs are byte-identical"),
// its counts match the live consts (non-vacuous), and every seeded product carries
// the catalog SKU (byte-faithful via the step-35 adapter). The store stays empty —
// this seed is not wired into any read-path until step 39.
import 'package:buildsmart/data/brands.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/data/smart_tree.dart';
import 'package:buildsmart/domain/seeds/plumbing_trade_seed.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buildPlumbingSeed is deterministic (two builds are equal)', () {
    expect(buildPlumbingSeed(), buildPlumbingSeed());
  });

  test('seed counts match the live consts (non-vacuous)', () {
    final seed = buildPlumbingSeed();
    expect(seed.trades, hasLength(1));
    expect(seed.trades.single.id, kPlumbingTradeId);
    expect(seed.products, hasLength(kCatalogProducts.length));
    expect(seed.fixtures, hasLength(kSmartProducts.length));
    expect(seed.trades.single.brandIds, hasLength(kBrands.length));
    expect(seed.categories, isNotEmpty);
    expect(seed.accessories, isNotEmpty);
  });

  test('every seeded product carries the exact catalog SKU set', () {
    final seed = buildPlumbingSeed();
    expect(
      seed.products.map((p) => p.id).toSet(),
      kCatalogProducts.map((p) => p.sku).toSet(),
    );
  });

  test('fixtures reference their accessory ids (links resolve)', () {
    final seed = buildPlumbingSeed();
    final accIds = seed.accessories.map((a) => a.id).toSet();
    for (final f in seed.fixtures) {
      for (final id in f.accessoryRuleIds) {
        expect(accIds, contains(id), reason: 'fixture ${f.id} links missing $id');
      }
    }
  });

  test('every category reference resolves (no dangling FKs)', () {
    final seed = buildPlumbingSeed();
    final catIds = seed.categories.map((c) => c.id).toSet();
    for (final p in seed.products) {
      expect(
        catIds,
        contains(p.categoryId),
        reason: 'product ${p.id} → dangling categoryId ${p.categoryId}',
      );
    }
    for (final f in seed.fixtures) {
      expect(
        catIds,
        contains(f.categoryId),
        reason: 'fixture ${f.id} → dangling categoryId ${f.categoryId}',
      );
    }
    for (final a in seed.accessories) {
      expect(
        catIds,
        contains(a.appliesToCategoryId),
        reason: 'accessory ${a.id} → dangling appliesToCategoryId '
            '${a.appliesToCategoryId}',
      );
    }
  });

  test('the _uncategorized fallback category exists', () {
    final seed = buildPlumbingSeed();
    expect(
      seed.categories.any((c) => c.id == 'plumbing.cat._uncategorized'),
      isTrue,
    );
  });

  test('products distribute across real categories (non-vacuous linkage)', () {
    final seed = buildPlumbingSeed();
    expect(seed.products.map((p) => p.categoryId).toSet().length, greaterThan(1));
  });
}
