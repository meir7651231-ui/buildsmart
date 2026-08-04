// CATALOG-CONFIG · Phase A browse-model unit test — pins that [browseSection]
// projects a catalog section into open families by `categoryHe == lipskeyCategory`,
// drops 0-product families, preserves tree order, and null-falls-back (never
// throws); and that [pilotSectionNode] returns the endparts section. Pure data:
// no Firebase, no widgets — exercised define-less (kCatalogConfig OFF).
// Template: test/config_schema_test.dart. SSOT: knowledge/CATALOG-CONFIG-PLAN.md (phase A).

import 'package:buildsmart/data/catalog_tree.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/features/catalog_config/browse_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// A minimal fake product — only the fields [browseSection] reads matter
/// (sku · nameHe · categoryHe · categoryEmoji); the rest satisfy the required
/// const-ctor params of [LipskeyCatalogProduct].
LipskeyCatalogProduct prod(
  String sku,
  String categoryHe, {
  String emoji = '🅰️',
  String? imageFile,
}) =>
    LipskeyCatalogProduct(
      sku: sku,
      nameHe: 'שם $sku',
      nameEn: 'name $sku',
      categoryHe: categoryHe,
      categoryEn: categoryHe,
      categoryEmoji: emoji,
      page: 1,
      imageFile: imageFile,
    );

/// A fake section exercising every branch: a DEEP leaf (catA, under a group),
/// a DIRECT leaf (catB), a leaf whose category has no products (catEmpty → drop),
/// and a leaf with NO lipskeyCategory (skip).
const CatalogNode kFakeSection = CatalogNode(
  id: 'sec',
  title: 'מקטע בדיקה',
  emoji: '🧪',
  children: [
    CatalogNode(
      id: 'sec.a',
      title: 'קבוצה א',
      emoji: '🅰️',
      children: [
        CatalogNode(
          id: 'sec.a.leaf',
          title: 'עלה A',
          emoji: '🍃',
          lipskeyCategory: 'catA',
        ),
      ],
    ),
    CatalogNode(
      id: 'sec.b',
      title: 'עלה B',
      emoji: '🅱️',
      lipskeyCategory: 'catB',
    ),
    CatalogNode(
      id: 'sec.empty',
      title: 'עלה ריק',
      emoji: '🈳',
      lipskeyCategory: 'catEmpty',
    ),
    CatalogNode(
      id: 'sec.nocat',
      title: 'ללא קטגוריה',
      emoji: '❔',
    ),
  ],
);

void main() {
  group('#catalog-config browse — browseSection groups by category', () {
    final products = [
      prod('A1', 'catA'),
      prod('A2', 'catA'),
      prod('B1', 'catB', emoji: '🅱️'),
      prod('Z9', 'catUnmapped'), // maps to no leaf → ignored entirely
    ];

    test('one family per matching leaf; section title carried through', () {
      final browse = browseSection(kFakeSection, products);
      expect(browse.titleHe, 'מקטע בדיקה');
      expect(browse.families.map((f) => f.id), ['sec.a.leaf', 'sec.b']);
      expect(browse.families.map((f) => f.titleHe), ['עלה A', 'עלה B']);
    });

    test('tiles carry the matching products, in list order', () {
      final browse = browseSection(kFakeSection, products);
      expect(browse.families.first.tiles.map((t) => t.sku), ['A1', 'A2']);
      expect(browse.families[1].tiles.map((t) => t.sku), ['B1']);
    });

    test('drops empty families (0 products) — never an empty rail', () {
      final browse = browseSection(kFakeSection, products);
      expect(browse.families.any((f) => f.id == 'sec.empty'), isFalse);
      expect(browse.families.every((f) => f.tiles.isNotEmpty), isTrue);
    });

    test('a leaf with NO lipskeyCategory is skipped', () {
      final browse = browseSection(kFakeSection, products);
      expect(browse.families.any((f) => f.id == 'sec.nocat'), isFalse);
    });

    test('preserves tree order — DFS pre-order (deep branch first)', () {
      // catA lives DEEPER (sec.a.leaf) but its branch precedes sec.b in the
      // tree, so it must come first.
      final browse = browseSection(kFakeSection, products);
      expect(browse.families.first.id, 'sec.a.leaf');
    });

    test('tile emoji = categoryEmoji, falls back to the leaf emoji when blank', () {
      final browse = browseSection(kFakeSection, [
        prod('A1', 'catA', emoji: '🔩'),
        prod('A2', 'catA', emoji: ''),
      ]);
      final tiles = browse.families.single.tiles;
      expect(tiles[0].emoji, '🔩'); // its own category emoji
      expect(tiles[1].emoji, '🍃'); // blank → the family (leaf) emoji fallback
    });
  });

  group('#catalog-config browse — ConfigTile carries the image (plan D)', () {
    test('fromProduct captures the product imageAsset (Lipskey path)', () {
      final tile =
          ConfigTile.fromProduct(prod('A1', 'catA', imageFile: 'a1.jpeg'));
      expect(tile.imageAsset, 'assets/lipskey/products/a1.jpeg');
    });

    test('a product with no image → null imageAsset (tolerant)', () {
      expect(ConfigTile.fromProduct(prod('A2', 'catA')).imageAsset, isNull);
    });

    test('the image flows through browseSection into the family tiles', () {
      final browse = browseSection(kFakeSection, [
        prod('A1', 'catA', imageFile: 'a1.jpeg'),
      ]);
      expect(
        browse.families.single.tiles.single.imageAsset,
        'assets/lipskey/products/a1.jpeg',
      );
    });
  });

  group('#catalog-config browse — null-fallback (never throws)', () {
    test('no products → an empty ConfigBrowse with the section title', () {
      final browse = browseSection(kFakeSection, const []);
      expect(browse.families, isEmpty);
      expect(browse.titleHe, 'מקטע בדיקה');
    });

    test('a childless section → empty families (never throws)', () {
      const bare = CatalogNode(id: 'x', title: 'ריק', emoji: '⬜');
      final browse = browseSection(bare, [prod('A1', 'catA')]);
      expect(browse.families, isEmpty);
      expect(browse.titleHe, 'ריק');
    });
  });

  group('#catalog-config browse — pilot section', () {
    test('pilotSectionNode() returns the endparts section', () {
      final node = pilotSectionNode();
      expect(node, isNotNull);
      expect(node!.id, 'endparts');
      expect(node.title, 'אביזרי קצה וחיבורים');
    });

    test('the pilot leaf endparts.threading.fittings carries אביזרי תבריג', () {
      final node = pilotSectionNode()!;
      final cats = <String>[];
      void walk(CatalogNode n) {
        final c = n.lipskeyCategory;
        if (n.isLeaf && c != null) {
          cats.add(c);
        }
        for (final child in n.children) {
          walk(child);
        }
      }

      walk(node);
      expect(cats, contains('אביזרי תבריג'));
    });
  });
}
