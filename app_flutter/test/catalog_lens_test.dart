// Guard for catalog_lens.dart — the list-level "lens" availability logic.
// Verifies: category always present; variant lens follows family membership;
// smart-tree lens follows the mapped-fraction threshold (approach א); chip
// labels are non-empty + distinct.

import 'package:buildsmart/data/catalog_lens.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/data/polyroll_specs.dart';
import 'package:buildsmart/data/smart_tree.dart';
import 'package:buildsmart/state/catalog_lens_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(registerPolyrollSpecs);

  group('CatalogLens labels', () {
    test('every lens has a non-empty emoji + Hebrew label', () {
      for (final l in CatalogLens.values) {
        expect(l.emoji, isNotEmpty);
        expect(l.labelHe, isNotEmpty);
        expect(l.chipLabel, contains(l.labelHe));
      }
    });

    test('labels are pairwise distinct', () {
      final labels = CatalogLens.values.map((l) => l.labelHe).toSet();
      expect(labels.length, CatalogLens.values.length);
    });
  });

  group('availableLensesForSet', () {
    test('empty set → category only', () {
      expect(availableLensesForSet(const []), [CatalogLens.category]);
    });

    test('category is ALWAYS present and ALWAYS first', () {
      final sets = <List<LipskeyCatalogProduct>>[
        kLipskeyCatalog.take(20).toList(),
        kPolyrollCatalog.take(20).toList(),
        kLipskeyCatalog.take(1).toList(),
      ];
      for (final s in sets) {
        final lenses = availableLensesForSet(s);
        expect(lenses.first, CatalogLens.category, reason: 'first must be category');
      }
    });

    test('copper fittings → category + variant, NO smart-tree (raw parts)', () {
      final copper =
          kLipskeyCatalog.where((p) => p.categoryHe == 'אביזרי נחושת').toList();
      expect(copper, isNotEmpty);
      final lenses = availableLensesForSet(copper);
      expect(lenses, contains(CatalogLens.category));
      expect(lenses, contains(CatalogLens.variant),
          reason: 'copper has size families (1/2", 3/4"…)');
      expect(lenses, isNot(contains(CatalogLens.smartTree)),
          reason: 'only ~8% of copper maps to smart-tree (< 25% threshold)');
    });

    test('PPR elbows → category + variant, NO smart-tree (0% map)', () {
      final elbows =
          kPolyrollCatalog.where((p) => p.categoryHe == 'ברכיים PPR').toList();
      expect(elbows, isNotEmpty);
      final lenses = availableLensesForSet(elbows);
      expect(lenses, isNot(contains(CatalogLens.smartTree)));
    });

    test('a fixture-rich set (all map to smart-tree) → includes smart-tree', () {
      // Build a set from real catalog products that DO map to a SmartProduct.
      final mapped = kLipskeyCatalog
          .where((p) => smartProductForSku(p.sku) != null)
          .take(10)
          .toList();
      expect(mapped, isNotEmpty);
      final lenses = availableLensesForSet(mapped);
      expect(lenses, contains(CatalogLens.smartTree),
          reason: '100% mapped → well above threshold');
    });
  });

  group('smart-tree threshold (injected, deterministic)', () {
    // Use a tiny crafted set with an injected family-sku set so the test is
    // independent of catalog data drift.
    test('exactly at the fraction → smart-tree included', () {
      // 1 of 4 maps = 25% == threshold → included (>=).
      final mapped = kLipskeyCatalog
          .firstWhere((p) => smartProductForSku(p.sku) != null);
      final unmapped = kPolyrollCatalog
          .where((p) => smartProductForSku(p.sku) == null)
          .take(3)
          .toList();
      final set = [mapped, ...unmapped];
      // Rely on the default threshold (kSmartTreeLensMinFraction = 0.25) so
      // this test pins the SHIPPING boundary.
      final lenses =
          availableLensesForSet(set, variantFamilySkus: const {});
      expect(lenses, contains(CatalogLens.smartTree),
          reason: '1/4 = 0.25 >= 0.25');
    });

    test('just under the fraction → smart-tree excluded', () {
      // 1 of 5 maps = 20% < 25% → excluded.
      final mapped = kLipskeyCatalog
          .firstWhere((p) => smartProductForSku(p.sku) != null);
      final unmapped = kPolyrollCatalog
          .where((p) => smartProductForSku(p.sku) == null)
          .take(4)
          .toList();
      final set = [mapped, ...unmapped];
      final lenses =
          availableLensesForSet(set, variantFamilySkus: const {});
      expect(lenses, isNot(contains(CatalogLens.smartTree)),
          reason: '1/5 = 0.20 < default 0.25');
    });

    test('variant lens follows injected family membership', () {
      final p = kLipskeyCatalog.first;
      // Threshold 2 (>100%) disables the smart-tree lens so this isolates the
      // variant axis.
      final withFam = availableLensesForSet([p],
          variantFamilySkus: {p.sku}, smartTreeMinFraction: 2);
      final without = availableLensesForSet([p],
          variantFamilySkus: const {}, smartTreeMinFraction: 2);
      expect(withFam, contains(CatalogLens.variant));
      expect(without, isNot(contains(CatalogLens.variant)));
    });
  });

  group('setSupportsLens', () {
    test('category supported for any non-empty set', () {
      expect(setSupportsLens(kLipskeyCatalog.take(3).toList(), CatalogLens.category),
          isTrue);
    });
  });

  group('groupByLens', () {
    test('category lens buckets by categoryHe — no product dropped', () {
      final set =
          [...kLipskeyCatalog.take(40), ...kPolyrollCatalog.take(40)];
      final groups = groupByLens(set, CatalogLens.category);
      // Every group title is a real categoryHe; total products == input.
      final total = groups.fold<int>(0, (s, g) => s + g.count);
      expect(total, set.length, reason: 'category lens drops nothing');
      // Titles are distinct (one bucket per category).
      final titles = groups.map((g) => g.title).toList();
      expect(titles.toSet().length, titles.length);
    });

    test('variant lens groups copper into families; nothing dropped', () {
      final copper =
          kLipskeyCatalog.where((p) => p.categoryHe == 'אביזרי נחושת').toList();
      final groups = groupByLens(copper, CatalogLens.variant);
      final total = groups.fold<int>(0, (s, g) => s + g.count);
      expect(total, copper.length,
          reason: 'variant lens keeps every product (singletons get own group)');
      // At least one MULTI-member family group exists (copper has size sets).
      expect(groups.any((g) => g.count > 1), isTrue);
    });

    test('smart-tree lens keeps ONLY mapped products, grouped by fixture', () {
      final set = [
        // a few that map + a few that don't
        ...kLipskeyCatalog.where((p) => smartProductForSku(p.sku) != null).take(8),
        ...kPolyrollCatalog.take(20), // PPR — none map
      ];
      final groups = groupByLens(set, CatalogLens.smartTree);
      final kept = groups.fold<int>(0, (s, g) => s + g.count);
      final mapped =
          set.where((p) => smartProductForSku(p.sku) != null).length;
      expect(kept, mapped, reason: 'unmapped products are dropped');
      expect(kept, lessThan(set.length), reason: 'PPR was dropped');
    });

    test('empty input → empty groups (every lens)', () {
      for (final l in CatalogLens.values) {
        expect(groupByLens(const [], l), isEmpty);
      }
    });
  });

  group('resolveActiveLens', () {
    test('keeps the selected lens when it is available', () {
      expect(
          resolveActiveLens(CatalogLens.variant,
              [CatalogLens.category, CatalogLens.variant]),
          CatalogLens.variant);
    });

    test('falls back to first available when selected is unavailable', () {
      expect(
          resolveActiveLens(
              CatalogLens.smartTree, [CatalogLens.category, CatalogLens.variant]),
          CatalogLens.category);
    });

    test('empty available → category (never strands)', () {
      expect(resolveActiveLens(CatalogLens.smartTree, const []),
          CatalogLens.category);
    });
  });
}
