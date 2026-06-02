import 'package:buildsmart/data/catalog_tree.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/data/smart_tree.dart';
import 'package:buildsmart/logic/system_division.dart';
import 'package:flutter_test/flutter_test.dart';

/// Unit tests for the water-system division (Benzi #1) — the logic that scopes
/// the catalog/finder to מים נקיים (supply) vs שפכים (drainage).
CatalogNode? _findNode(String title) {
  CatalogNode? hit;
  void walk(CatalogNode n) {
    if (hit != null) return;
    if (n.title == title) {
      hit = n;
      return;
    }
    for (final c in n.children) {
      walk(c);
    }
  }

  for (final root in kCatalogTree) {
    walk(root);
  }
  return hit;
}

void main() {
  group('productDivisionSystems', () {
    test('PPR (פולירול) without a static spec → supply (clean water)', () {
      final ppr = kCatalogProducts.firstWhere(
          (p) => p.brand == 'פולירול' && !kVerifiedSpecs.containsKey(p.sku));
      expect(productDivisionSystems(ppr), {WaterSystem.supply});
    });

    test('a SKU with a verified spec returns that spec\'s endSystems', () {
      final entry = kVerifiedSpecs.entries
          .firstWhere((e) => e.value.endSystems.isNotEmpty);
      final matches =
          kCatalogProducts.where((p) => p.sku == entry.key).toList();
      if (matches.isNotEmpty) {
        expect(productDivisionSystems(matches.first), entry.value.endSystems);
      }
    });

    test('non-PPR with no spec → drainage (default)', () {
      final p = kCatalogProducts.firstWhere(
          (p) => p.brand != 'פולירול' && !kVerifiedSpecs.containsKey(p.sku));
      expect(productDivisionSystems(p), {WaterSystem.drainage});
    });

    test('every product classifies into at least one system', () {
      expect(kCatalogProducts.every((p) => productDivisionSystems(p).isNotEmpty),
          isTrue);
    });
  });

  group('filterBySystem', () {
    test('null system → identity (same items, unchanged)', () {
      final list = kCatalogProducts.take(50).toList();
      expect(filterBySystem(list, null), same(list));
    });

    test('supply filter keeps only supply products', () {
      final out = filterBySystem(kCatalogProducts, WaterSystem.supply);
      expect(out, isNotEmpty);
      expect(
          out.every((p) =>
              productDivisionSystems(p).contains(WaterSystem.supply)),
          isTrue);
    });

    test('supply + drainage together cover the whole catalog', () {
      final supply = filterBySystem(kCatalogProducts, WaterSystem.supply);
      final drain = filterBySystem(kCatalogProducts, WaterSystem.drainage);
      expect(supply, isNotEmpty);
      expect(drain, isNotEmpty);
      // Each product is in ≥1 system (fixtures count in both), so the two lists
      // cover every product — neither side silently drops a classified product.
      expect(supply.length + drain.length,
          greaterThanOrEqualTo(kCatalogProducts.length));
    });
  });

  group('nodeHasSystem', () {
    test('a fixture node (אסלות) shows under BOTH systems', () {
      final fixture = _findNode('אסלות');
      expect(fixture, isNotNull, reason: 'אסלות must exist in the catalog tree');
      expect(nodeHasSystem(fixture!, WaterSystem.supply), isTrue);
      expect(nodeHasSystem(fixture, WaterSystem.drainage), isTrue);
    });

    test('a top category belongs to at least one system', () {
      final node = kCatalogTree.first;
      expect(
          nodeHasSystem(node, WaterSystem.supply) ||
              nodeHasSystem(node, WaterSystem.drainage),
          isTrue);
    });

    test('category division discriminates — some supply-only, some drain-only',
        () {
      // Phase 2 filters the קטגוריות / הכל / מועדפים sections by this exact
      // logic, so the division is only meaningful if categories actually split
      // onto one side (fixtures land on both; these are the non-fixtures).
      bool supplyOnly(CatalogNode n) =>
          nodeHasSystem(n, WaterSystem.supply) &&
          !nodeHasSystem(n, WaterSystem.drainage);
      bool drainOnly(CatalogNode n) =>
          nodeHasSystem(n, WaterSystem.drainage) &&
          !nodeHasSystem(n, WaterSystem.supply);
      expect(kCatalogTree.any(supplyOnly), isTrue,
          reason: 'expected at least one supply-only top category');
      expect(kCatalogTree.any(drainOnly), isTrue,
          reason: 'expected at least one drainage-only top category');
    });
  });

  group('smart-tree division (Phase 2b)', () {
    test('null system → identity (same list, no filtering)', () {
      for (final c in kSmartTreeCats) {
        final all = smartProductsForCat(c);
        expect(filterSmartBySystem(all, null), same(all));
      }
    });

    test('every smart product stays reachable under supply ∪ drainage', () {
      // Unresolvable products show in both; resolvable ones in their system(s).
      // Either way none may vanish from BOTH when a system is selected.
      for (final c in kSmartTreeCats) {
        final all = smartProductsForCat(c);
        final sup = filterSmartBySystem(all, WaterSystem.supply).toSet();
        final dr = filterSmartBySystem(all, WaterSystem.drainage).toSet();
        for (final p in all) {
          expect(sup.contains(p) || dr.contains(p), isTrue,
              reason: '${p.name} vanished from both systems');
        }
      }
    });

    test('brand-SKU mapping resolves for at least some smart products', () {
      // Guards against the mapping silently becoming a no-op (then everything
      // would be "unresolvable" → shown everywhere, i.e. no real filtering).
      final resolved = kSmartTreeCats
          .expand(smartProductsForCat)
          .where((p) => smartProductSystems(p).isNotEmpty);
      expect(resolved, isNotEmpty,
          reason: 'no smart product mapped to a system — mapping is a no-op');
    });

    test('filter discriminates — supply and drainage pools genuinely differ',
        () {
      // Some smart products are exclusive to one system, so the two filtered
      // pools must differ AND each be a strict subset — guards against the
      // filter degrading into a pass-through (which would hide nothing).
      final all = kSmartTreeCats.expand(smartProductsForCat).toList();
      final sup = filterSmartBySystem(all, WaterSystem.supply);
      final dr = filterSmartBySystem(all, WaterSystem.drainage);
      expect(sup.length, isNot(equals(dr.length)));
      expect(sup.length, lessThan(all.length));
      expect(dr.length, lessThan(all.length));
    });
  });
}
