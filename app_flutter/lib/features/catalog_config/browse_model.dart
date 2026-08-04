// ─────────────────────────────────────────────────────────────────────────────
// CATALOG-CONFIG · Phase A — the BROWSE layer model. PURE, data-driven, widget-
// free (no Flutter widgets, no Firebase) so it is unit-testable define-less. It
// walks a catalog SECTION into "families פתוחות" (a family = a tree leaf that
// carries a `lipskeyCategory`) each holding its product TILES — exactly the
// design's open-rail dive (§המסך: section → families=מחלקות → אריחי-מוצר).
// SSOT: knowledge/CATALOG-CONFIG-PLAN.md (§המסך, phase A).
//
// GROUNDED (build on the live code, don't reinvent — plan 🛡️):
//   • families ← the catalog tree (`CatalogNode`/`kCatalogTree`, data/catalog_tree)
//     — a leaf maps to products iff `product.categoryHe == leaf.lipskeyCategory`
//     (the existing catalog contract, mirrored in data/catalog_source).
//   • tiles    ← `LipskeyCatalogProduct` (sku · nameHe · categoryEmoji).
//
// GATING: pure data + pure projection — NO `kCatalogConfig` branch of its own. In
// a define-less APP build nothing imports it except the gated dive SCREEN
// (compile-gated behind `if (kCatalogConfig)`), so it tree-shakes out ⇒ byte-
// identical-off. The unit test references it directly (pure ⇒ exercised OFF).
//
// null-fallback (plan 🛡️): no products / an empty (childless) section → an empty
// [ConfigBrowse] — never throws, never an empty rail (0-product families drop).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/catalog_tree.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:flutter/foundation.dart';

/// One product tile in an open family rail — the leaf-level unit the user taps
/// to open the (phase-B) config card. Identity + display only (pure data).
@immutable
class ConfigTile {
  const ConfigTile({
    required this.sku,
    required this.nameHe,
    required this.emoji,
    this.imageAsset,
  });

  /// Build a tile from a catalog product. [emoji] is the product's
  /// [LipskeyCatalogProduct.categoryEmoji], or [fallbackEmoji] when that is
  /// blank (plan A.2 · null-fallback — a tile is never emoji-less); [imageAsset]
  /// carries the product's primary image ([LipskeyCatalogProduct.imageAsset],
  /// plan D — may be null, tolerated).
  factory ConfigTile.fromProduct(
    LipskeyCatalogProduct product, {
    String fallbackEmoji = '📦',
  }) {
    final emoji = product.categoryEmoji.isNotEmpty
        ? product.categoryEmoji
        : fallbackEmoji;
    return ConfigTile(
      sku: product.sku,
      nameHe: product.nameHe,
      emoji: emoji,
      imageAsset: product.imageAsset,
    );
  }

  /// Catalog sku (identity) — the phase-B config card / cart line keys on this.
  final String sku;

  /// Hebrew product name (the tile label).
  final String nameHe;

  /// The tile icon (resolved, never empty).
  final String emoji;

  /// The product's primary image asset path
  /// ([LipskeyCatalogProduct.imageAsset]), or null when the product has no
  /// image. The phase-D card resolves this to the center image and falls back to
  /// [emoji] when absent (plan D.2 · never empty). Tolerant — null is fine.
  final String? imageAsset;

  @override
  bool operator ==(Object other) =>
      other is ConfigTile &&
      other.sku == sku &&
      other.nameHe == nameHe &&
      other.emoji == emoji &&
      other.imageAsset == imageAsset;

  @override
  int get hashCode => Object.hash(sku, nameHe, emoji, imageAsset);
}

/// A family = a catalog tree LEAF that carries a `lipskeyCategory`, with the
/// products that map to it as [tiles]. "משפחה פתוחה" — its rail is always
/// visible in the dive. Never built empty ([browseSection] drops 0-tile leaves).
@immutable
class ConfigFamily {
  const ConfigFamily({
    required this.id,
    required this.titleHe,
    required this.emoji,
    required this.tiles,
  });

  /// The source leaf's id (stable) — e.g. `endparts.threading.fittings`.
  final String id;

  /// The family (מחלקה) title — the leaf's Hebrew title.
  final String titleHe;

  /// The family header icon — the leaf's emoji.
  final String emoji;

  /// The product tiles in this family, in catalog-list order. Non-empty.
  final List<ConfigTile> tiles;

  @override
  bool operator ==(Object other) =>
      other is ConfigFamily &&
      other.id == id &&
      other.titleHe == titleHe &&
      other.emoji == emoji &&
      listEquals(other.tiles, tiles);

  @override
  int get hashCode => Object.hash(id, titleHe, emoji, Object.hashAll(tiles));
}

/// A browse SECTION — the dive screen's whole payload: a section title plus its
/// open families, in tree order. Empty [families] ⇒ the screen shows its empty
/// state (never throws).
@immutable
class ConfigBrowse {
  const ConfigBrowse({required this.titleHe, required this.families});

  /// The section title (the dive screen's app-bar title).
  final String titleHe;

  /// The section's non-empty families, in tree (DFS pre-order) order.
  final List<ConfigFamily> families;

  @override
  bool operator ==(Object other) =>
      other is ConfigBrowse &&
      other.titleHe == titleHe &&
      listEquals(other.families, families);

  @override
  int get hashCode => Object.hash(titleHe, Object.hashAll(families));
}

/// PURE + deterministic — walk [section]'s subtree, collect every leaf that
/// carries a `lipskeyCategory`, and build a [ConfigFamily] per leaf holding the
/// [products] whose `categoryHe == lipskeyCategory`. A family with 0 products is
/// dropped (no empty rails); ordering is tree order (DFS pre-order over the
/// section). null-fallback: no products / a childless section → an empty
/// [ConfigBrowse] carrying only the section title (never throws).
ConfigBrowse browseSection(
  CatalogNode section,
  List<LipskeyCatalogProduct> products,
) {
  // Bucket products by their Lipskey category once (O(n)) — each family is then
  // an O(1) lookup, and a bucket preserves the products' list order.
  final byCategory = <String, List<LipskeyCatalogProduct>>{};
  for (final product in products) {
    byCategory
        .putIfAbsent(product.categoryHe, () => <LipskeyCatalogProduct>[])
        .add(product);
  }

  final families = <ConfigFamily>[];
  void walk(CatalogNode node) {
    // Local so the null-check promotes it to non-null (public fields don't).
    final category = node.lipskeyCategory;
    if (node.isLeaf && category != null) {
      final matches = byCategory[category] ?? const <LipskeyCatalogProduct>[];
      if (matches.isNotEmpty) {
        families.add(
          ConfigFamily(
            id: node.id,
            titleHe: node.title,
            emoji: node.emoji,
            tiles: [
              for (final product in matches)
                ConfigTile.fromProduct(product, fallbackEmoji: node.emoji),
            ],
          ),
        );
      }
    }
    for (final child in node.children) {
      walk(child);
    }
  }

  walk(section);
  return ConfigBrowse(titleHe: section.title, families: families);
}

/// The pilot section (plan phase F.1 · G): `אביזרי קצה וחיבורים` — the top-level
/// `kCatalogTree` node with `id == 'endparts'`, or null if it is ever removed.
CatalogNode? pilotSectionNode() {
  for (final section in kCatalogTree) {
    if (section.id == 'endparts') {
      return section;
    }
  }
  return null;
}
