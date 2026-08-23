// ─────────────────────────────────────────────────────────────────────────────
// Pillar-2 Step 42 — pins the tradeId seam on the catalog repository: default
// 'plumbing' keeps every existing caller byte-identical (the formal
// backward-compat contract); unknown trades read empty until the authored
// read-path lands (s43+, trades-store wiring).
//
// The seam under test (the s42 builder contract):
//   • the read methods `allProducts` / `catalogCategories` / `smartTreeCats`
//     gain an OPTIONAL named `{String tradeId = 'plumbing'}`;
//   • a NEW `categoryTree({String tradeId = 'plumbing'})` returning
//     `List<CatalogNode>` lands with a DEFAULT implementation on the abstract
//     class (so other impls keep compiling);
//   • tradeId 'plumbing' — or omitted — serves EXACTLY today's data:
//     kCatalogProducts / kCatalogCats / kSmartTreeCats-content / kCatalogTree;
//   • ANY other tradeId reads empty (v1 — the authored trades read-path
//     arrives with the trades-store wiring in later steps).
//
// NOTE: kSmartTreeCats is a DERIVED GETTER (fresh list per access), so parity
// for smartTreeCats is content equality BY DESIGN. The other three sources are
// single top-level lists, so element-identity spot checks are also pinned
// (they survive a shallow copy; only a forbidden deep rebuild breaks them).
// ─────────────────────────────────────────────────────────────────────────────

// The whole point of this file is calling the reads WITH the explicit default
// ('plumbing') and asserting they equal the omitted form — so the redundant-
// argument lint is structurally at odds with the very contract being pinned.
// ignore_for_file: avoid_redundant_argument_values

import 'package:buildsmart/data/catalog.dart' show kCatalogCats;
import 'package:buildsmart/data/catalog_tree.dart'
    show CatalogNode, kCatalogTree;
import 'package:buildsmart/data/lipskey_catalog.dart'
    show LipskeyCatalogProduct;
import 'package:buildsmart/data/polyroll_catalog.dart' show kCatalogProducts;
import 'package:buildsmart/data/repositories/catalog_local.dart'
    show catalogRepositoryProvider;
import 'package:buildsmart/data/repositories/catalog_repository.dart'
    show CatalogRepository;
import 'package:buildsmart/data/sections.dart' show Section;
import 'package:buildsmart/data/smart_tree.dart' show kSmartTreeCats;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Reads the repo through the provider — the same construction idiom as
/// `repositories_test.dart` (the exact seam the screens consume).
CatalogRepository _readRepo() {
  final c = ProviderContainer();
  addTearDown(c.dispose);
  return c.read(catalogRepositoryProvider);
}

/// Content projections — the classes override no `==`, so byte-equality is
/// asserted on the stable keys (sku / id), in order.
List<String> _skus(List<LipskeyCatalogProduct> products) =>
    [for (final p in products) p.sku];

List<String> _nodeIds(List<CatalogNode> nodes) =>
    [for (final n in nodes) n.id];

List<String> _sectionIds(List<Section> sections) =>
    [for (final s in sections) s.id];

void main() {
  group('S42 — tradeId seam on CatalogRepository', () {
    test(
        'allProducts(): omitted tradeId == explicit plumbing — '
        'the default is the seam', () {
      final repo = _readRepo();
      final omitted = repo.allProducts();
      final plumbing = repo.allProducts(tradeId: 'plumbing');

      expect(omitted, isNotEmpty);
      expect(plumbing.length, omitted.length);
      expect(_skus(plumbing), orderedEquals(_skus(omitted)));
    });

    test('allProducts(tradeId: plumbing) is byte-equal to kCatalogProducts',
        () {
      final repo = _readRepo();
      final got = repo.allProducts(tradeId: 'plumbing');

      expect(got.length, kCatalogProducts.length);
      expect(_skus(got), orderedEquals(_skus(kCatalogProducts)));
      // Same OBJECTS, not just same skus — the local impl serves the existing
      // unified list (no recompute), so row identity must survive the seam
      // (spot checks; they hold even across a shallow copy).
      expect(got.first, same(kCatalogProducts.first));
      expect(got.last, same(kCatalogProducts.last));
    });

    test(
        'categoryTree(tradeId: plumbing) is kCatalogTree; '
        'categoryTree() defaults to plumbing', () {
      final repo = _readRepo();
      final plumbing = repo.categoryTree(tradeId: 'plumbing');
      final omitted = repo.categoryTree();

      // The plumbing tree IS today's kCatalogTree — roots in order, and the
      // real L1→L2→L3 drill (not a stub of hollow nodes).
      expect(plumbing, isNotEmpty);
      expect(plumbing.length, kCatalogTree.length);
      expect(_nodeIds(plumbing), orderedEquals(_nodeIds(kCatalogTree)));
      expect(
        [for (final n in plumbing) n.title],
        orderedEquals([for (final n in kCatalogTree) n.title]),
      );
      expect(plumbing.any((n) => n.children.isNotEmpty), isTrue);
      expect(plumbing.first, same(kCatalogTree.first));
      expect(plumbing.last, same(kCatalogTree.last));

      // No-arg defaults to the plumbing tree.
      expect(omitted.length, kCatalogTree.length);
      expect(_nodeIds(omitted), orderedEquals(_nodeIds(plumbing)));
    });

    test(
        'catalogCategories / smartTreeCats: no-arg == plumbing-arg, '
        'content == the const sources', () {
      final repo = _readRepo();

      // catalogCategories — mirrors kCatalogCats (the ▦ top categories).
      final catsOmitted = repo.catalogCategories();
      final catsPlumbing = repo.catalogCategories(tradeId: 'plumbing');
      expect(catsOmitted, isNotEmpty);
      expect(_sectionIds(catsPlumbing), orderedEquals(_sectionIds(catsOmitted)));
      expect(_sectionIds(catsOmitted), orderedEquals(_sectionIds(kCatalogCats)));

      // smartTreeCats — kSmartTreeCats is a DERIVED GETTER (fresh list per
      // access), so the parity contract here is content equality by design.
      final smartOmitted = repo.smartTreeCats();
      final smartPlumbing = repo.smartTreeCats(tradeId: 'plumbing');
      expect(smartOmitted, isNotEmpty);
      expect(smartPlumbing, orderedEquals(smartOmitted));
      expect(smartOmitted, orderedEquals(kSmartTreeCats));
    });

    test('unknown trade reads empty on every read (v1 contract)', () {
      final repo = _readRepo();

      expect(repo.allProducts(tradeId: 'electric'), isEmpty);
      expect(repo.categoryTree(tradeId: 'electric'), isEmpty);
      expect(repo.catalogCategories(tradeId: 'electric'), isEmpty);
      expect(repo.smartTreeCats(tradeId: 'electric'), isEmpty);

      // Not an 'electric' special case — ANY non-plumbing trade is empty in
      // v1 (the authored trades read-path lands s43+).
      expect(repo.allProducts(tradeId: 'gardening'), isEmpty);
      expect(repo.categoryTree(tradeId: 'gardening'), isEmpty);
    });

    test(
        'backward-compat contract: EVERY read with tradeId omitted '
        'equals tradeId plumbing', () {
      final repo = _readRepo();

      // One grouped assertion per read method (plan addition-B): calling with
      // tradeId omitted must equal calling with tradeId 'plumbing' — the
      // formal statement that the seam changes NOTHING for existing callers.
      final pairs = <String, ({List<String> omitted, List<String> plumbing})>{
        'allProducts': (
          omitted: _skus(repo.allProducts()),
          plumbing: _skus(repo.allProducts(tradeId: 'plumbing')),
        ),
        'categoryTree': (
          omitted: _nodeIds(repo.categoryTree()),
          plumbing: _nodeIds(repo.categoryTree(tradeId: 'plumbing')),
        ),
        'catalogCategories': (
          omitted: _sectionIds(repo.catalogCategories()),
          plumbing: _sectionIds(repo.catalogCategories(tradeId: 'plumbing')),
        ),
        'smartTreeCats': (
          omitted: repo.smartTreeCats(),
          plumbing: repo.smartTreeCats(tradeId: 'plumbing'),
        ),
      };

      pairs.forEach((method, pair) {
        expect(
          pair.omitted,
          isNotEmpty,
          reason: '$method(): the plumbing default must serve the live data '
              '(an empty pair would pass vacuously)',
        );
        expect(
          pair.plumbing,
          orderedEquals(pair.omitted),
          reason: '$method(): tradeId omitted must equal tradeId plumbing',
        );
      });
    });
  });
}
