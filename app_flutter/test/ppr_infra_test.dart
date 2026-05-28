// Verifies the Polyroll/Heliroma PPR ingestion scaffold end-to-end, using the
// exact resolution the catalog UI uses (categoryHe == leaf.lipskeyCategory over
// kCatalogProducts). Doubles as a regression guard for the infrastructure.
import 'package:flutter_test/flutter_test.dart';

import 'package:buildsmart/data/brands.dart';
import 'package:buildsmart/data/catalog.dart';
import 'package:buildsmart/data/catalog_tree.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/data/variant_families.dart';
import 'package:buildsmart/screens/finder_screen.dart';

CatalogNode _pprRoot() => kCatalogTree.firstWhere((n) => n.id == 'ppr');

List<CatalogNode> _leaves(CatalogNode n) {
  final out = <CatalogNode>[];
  void rec(CatalogNode x) => x.isLeaf ? out.add(x) : x.children.forEach(rec);
  rec(n);
  return out;
}

void main() {
  test('PPR · L1 category + sub-tree structure', () {
    final root = _pprRoot();
    final leaves = _leaves(root);
    print('\n┌─ ${root.emoji} ${root.title}');
    for (final branch in root.children) {
      print('├─ ${branch.emoji} ${branch.title}'
          '${branch.isLeaf ? "  (leaf)" : ""}');
      for (final c in branch.children) {
        print('│   • ${c.emoji} ${c.title}  →  ${c.lipskeyCategory}');
      }
    }
    print('└─ ${root.children.length} תת-קבוצות · ${leaves.length} עלים\n');
    expect(root.title, contains('PPR'));
    expect(leaves.length, kPprCategories.length);
    // every leaf carries a polyroll brand + a category
    for (final l in leaves) {
      expect(l.brandIds, contains('polyroll'));
      expect(l.lipskeyCategory, isNotNull);
    }
  });

  test('PPR · every leaf resolves to products (the real UI query)', () {
    final root = _pprRoot();
    var total = 0;
    print('');
    for (final leaf in _leaves(root)) {
      // EXACT query catalog_screen.dart runs for a product leaf:
      final prods = kCatalogProducts
          .where((p) => p.categoryHe == leaf.lipskeyCategory)
          .toList();
      final sample = prods.take(2).map((p) => p.nameHe).join(' · ');
      print('${prods.length.toString().padLeft(2)} | ${leaf.title}  ›  $sample');
      expect(prods, isNotEmpty, reason: 'leaf "${leaf.title}" has 0 products');
      total += prods.length;
    }
    print('───\nסה"כ פריטי PPR שמגיעים דרך העץ: $total\n');
    expect(total, kPolyrollCatalog.length);
  });

  test('PPR · seed integrity — brand / category / unique sku', () {
    final cats = kPprCategories.toSet();
    for (final p in kPolyrollCatalog) {
      expect(p.brand, kPolyrollBrand);
      expect(cats.contains(p.categoryHe), isTrue,
          reason: '${p.sku}: categoryHe "${p.categoryHe}" not a PPR category');
      expect(p.sku.trim().isNotEmpty && p.nameHe.trim().isNotEmpty, isTrue);
    }
    final skus = kPolyrollCatalog.map((p) => p.sku).toList();
    expect(skus.toSet().length, skus.length, reason: 'duplicate Polyroll SKU');
    expect(brandById('polyroll'), isNotNull, reason: 'brand not registered');
  });

  test('PPR · variant engine works on PPR data (pipes → size picker)', () {
    final pipes = kCatalogProducts
        .where((p) => p.categoryHe == kPprPipesSupply)
        .toList();
    final sizes = pipes
        .map((p) => variantValue(p, AttrKind.size))
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    print('\nצינורות אספקת מים — מידות שהמנוע זיהה: $sizes\n');
    expect(sizes.length, greaterThan(1),
        reason: 'size variant picker needs ≥2 distinct sizes');
  });

  test('PPR · REACHABLE in the UI (categories list + finder group)', () {
    final treeTitle = _pprRoot().title;
    // "קטגוריות" view: _CatalogList rows come from kCatalogCats and link to the
    // tree node by title — without a matching Section the branch is orphaned.
    expect(kCatalogCats.any((s) => s.title == treeTitle), isTrue,
        reason: 'no kCatalogCats Section titled "$treeTitle" → PPR unreachable '
            'from the "קטגוריות" view');
    // "בית" (FinderScreen): one group must cover exactly the 12 PPR categories.
    final pprGroups = kFinderGroups.where((g) =>
        g.cats.length == kPprCategories.length &&
        kPprCategories.every(g.cats.contains));
    expect(pprGroups.length, 1,
        reason: 'FinderScreen needs exactly one PPR group covering all 12 '
            'PPR categories → else PPR is missing/mis-grouped in "בית"');
    print('\nreachable: קטגוריות ✓ (Section "$treeTitle")  ·  '
        'בית ✓ (group "${pprGroups.first.label}")\n');
  });

  test('PPR · unified catalog = Lipskey + Polyroll', () {
    print('\nkLipskeyCatalog=${kLipskeyCatalog.length}  '
        'kPolyrollCatalog=${kPolyrollCatalog.length}  '
        'kCatalogProducts=${kCatalogProducts.length}\n');
    expect(kCatalogProducts.length,
        kLipskeyCatalog.length + kPolyrollCatalog.length);
  });
}
