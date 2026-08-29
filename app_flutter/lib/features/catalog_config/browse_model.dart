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
import 'package:buildsmart/data/variant_families.dart';
import 'package:buildsmart/features/catalog_config/catalog_taxonomy.dart';
import 'package:buildsmart/features/catalog_config/image_quality.dart';
import 'package:flutter/foundation.dart';

/// The representative product of [group] — the one with the BRIGHTEST image
/// ([imageBrightness] · owner: the clearest, most-central photo, never a black
/// tile). Relative, not an absolute cutoff: a type is represented by its best
/// available photo. Never empty (falls back to [group].first when none is pictured).
LipskeyCatalogProduct _pickRep(List<LipskeyCatalogProduct> group) {
  LipskeyCatalogProduct? best;
  var bestB = -2;
  for (final p in group) {
    if (p.imageAsset == null) continue;
    final b = imageBrightness(p.imageAsset);
    if (b > bestB) {
      bestB = b;
      best = p;
    }
  }
  return best ?? group.first;
}

/// The representative IMAGE of [rep] — its photo unless that is genuinely black
/// ([isBrightImage] false, below the dark floor), in which case null ⇒ the caller
/// shows the emoji, so a tile/header is NEVER black (owner).
String? _repImage(LipskeyCatalogProduct rep) =>
    isBrightImage(rep.imageAsset) ? rep.imageAsset : null;

/// One product tile in an open family rail — the leaf-level unit the user taps
/// to open the (phase-B) config card. Identity + display only (pure data).
@immutable
class ConfigTile {
  const ConfigTile({
    required this.sku,
    required this.nameHe,
    required this.emoji,
    this.imageAsset,
    this.materialHe = '',
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

  /// The tile's canonical MATERIAL (PPR · HDPE · נחושת · …), or `''` when the
  /// product carries no detected material. The family rail pages by this — a
  /// header swipe walks the materials (owner: "מושך את הכותרת → סוג החומר").
  final String materialHe;

  @override
  bool operator ==(Object other) =>
      other is ConfigTile &&
      other.sku == sku &&
      other.nameHe == nameHe &&
      other.emoji == emoji &&
      other.imageAsset == imageAsset &&
      other.materialHe == materialHe;

  @override
  int get hashCode => Object.hash(sku, nameHe, emoji, imageAsset, materialHe);
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
    required this.productCount,
  });

  /// The source leaf's id (stable) — e.g. `endparts.threading.fittings`.
  final String id;

  /// The family (מחלקה) title — the leaf's Hebrew title.
  final String titleHe;

  /// The family header icon — the leaf's emoji.
  final String emoji;

  /// The TYPE tiles in this family, in catalog-list order — ONE per variant
  /// family ([productCanonicalKey]); the per-SKU variations are collapsed into
  /// the card's wheels. Non-empty.
  final List<ConfigTile> tiles;

  /// The total PRODUCT count in this family (all variations, before collapse) —
  /// the sub-header badge (the mockup's "· 143"), NOT the tile/type count.
  final int productCount;

  /// The family's REPRESENTATIVE image (plan D · DERIVED, never hardcoded): the
  /// first tile that carries a BRIGHT [ConfigTile.imageAsset] ([isBrightImage] ·
  /// owner: never a black header), else the first with any image. So the family
  /// sub-header shows a real, CLEAR product photo pulled from the live catalog — it
  /// SURVIVES a catalog delete-and-reupload (there is NO family→image map, the north
  /// star). null ⇒ no pictured product (→ the header falls back to [emoji]).
  String? get representativeImage {
    for (final tile in tiles) {
      if (isBrightImage(tile.imageAsset)) {
        return tile.imageAsset;
      }
    }
    for (final tile in tiles) {
      if (tile.imageAsset != null) {
        return tile.imageAsset;
      }
    }
    return null;
  }

  /// The sub-header badge — the total product count (all variations).
  int get count => productCount;

  /// The distinct MATERIALS in this family, in rail order (PPR · HDPE · נחושת · …,
  /// the material-less group `''` last). The header pages through these; the rail
  /// shows one at a time (owner: a header swipe = the material). Since [tiles] are
  /// already material-grouped, first-appearance preserves the order.
  List<String> get materials {
    final seen = <String>[];
    for (final tile in tiles) {
      if (!seen.contains(tile.materialHe)) seen.add(tile.materialHe);
    }
    return seen;
  }

  /// The tiles carrying [material] — one material page's content.
  List<ConfigTile> tilesFor(String material) =>
      [for (final tile in tiles) if (tile.materialHe == material) tile];

  @override
  bool operator ==(Object other) =>
      other is ConfigFamily &&
      other.id == id &&
      other.titleHe == titleHe &&
      other.emoji == emoji &&
      other.productCount == productCount &&
      listEquals(other.tiles, tiles);

  @override
  int get hashCode =>
      Object.hash(id, titleHe, emoji, productCount, Object.hashAll(tiles));
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

/// Collapse a family's products into ONE [ConfigTile] per variant family (the
/// existing [productCanonicalKey] — every size/color/model/subtype variant of the
/// same product shares one key), so the rail shows TYPES and the config card's
/// wheels carry the variations (owner: "הרַיל = סוגים, הכרטיס = וריאציות"). Reuses
/// the built variant engine — no new grouping, no name-heuristic. Groups keep
/// first-appearance (catalog) order.
List<ConfigTile> _collapseTiles(
  List<LipskeyCatalogProduct> products,
  String fallbackEmoji,
) {
  final groups = <String, List<LipskeyCatalogProduct>>{};
  final order = <String>[];
  for (final product in products) {
    final key = productCanonicalKey(product);
    final list = groups[key];
    if (list == null) {
      groups[key] = [product];
      order.add(key);
    } else {
      list.add(product);
    }
  }
  return [
    for (final key in order) _tileForGroup(groups[key]!, fallbackEmoji),
  ];
}

/// One tile for a collapsed variant group — sku + image from the first pictured
/// member (else the first, plan D); label = the [productFrame] (falls back to the
/// full name for a too-short frame); emoji = the member's categoryEmoji else
/// [fallbackEmoji].
ConfigTile _tileForGroup(
  List<LipskeyCatalogProduct> group,
  String fallbackEmoji,
) {
  final rep = _pickRep(group);
  final frame = productFrame(rep);
  final emoji = tileEmoji(
    rep.categoryEmoji.isNotEmpty ? rep.categoryEmoji : fallbackEmoji,
  );
  return ConfigTile(
    sku: rep.sku,
    nameHe: frame.length >= 3 ? frame : rep.nameHe,
    emoji: emoji,
    imageAsset: _repImage(rep),
  );
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
            productCount: matches.length,
            tiles: _collapseTiles(matches, node.emoji),
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

/// The WHOLE-catalog browse (owner §1·§2) — grouped by the clean FAMILY
/// ([familyGroupOf], the ~12 owner category groups) → TYPE tiles ([typeWordOf], the
/// canonical word within the family). Each type collapses ALL its variants (any
/// size/angle/material) into ONE tile; the card's wheels carry the variations. This
/// REPLACES the per-leaf tree walk against fragmentation (93 leaves → ~12 families).
/// Family + type keep first-appearance (catalog) order.
ConfigBrowse browseAll(List<LipskeyCatalogProduct> products) {
  // family -> ordered (material⋄type) group keys · groupKey -> products + material.
  // A TYPE splits per MATERIAL (owner: header swipe = the material) — the same ברך
  // becomes a PPR tile, an HDPE tile and a נחושת tile, and the rail orders them by
  // material so paging the header walks PPR → HDPE → נחושת.
  final familyGroups = <String, List<String>>{};
  final byGroup = <String, List<LipskeyCatalogProduct>>{};
  final groupMaterial = <String, String>{};
  final familyOrder = <String>[];
  final familyEmoji = <String, String>{};
  for (final product in products) {
    final family = familyGroupOf(product);
    final material = materialOf(product);
    final groupKey = '$material${typeKeyOf(product)}';
    if (!familyGroups.containsKey(family)) {
      familyOrder.add(family);
      familyGroups[family] = <String>[];
      familyEmoji[family] = product.categoryEmoji;
    }
    final list = byGroup[groupKey];
    if (list == null) {
      byGroup[groupKey] = [product];
      familyGroups[family]!.add(groupKey);
      groupMaterial[groupKey] = material;
    } else {
      list.add(product);
    }
  }
  return ConfigBrowse(
    titleHe: 'כל הקטלוג',
    families: [
      for (final family in familyOrder)
        ConfigFamily(
          id: family,
          titleHe: family,
          emoji: tileEmoji(familyEmoji[family]!),
          productCount:
              familyGroups[family]!.fold(0, (sum, k) => sum + byGroup[k]!.length),
          tiles: [
            for (final key
                in _byMaterialThenType(familyGroups[family]!, groupMaterial))
              _typeTile(byGroup[key]!, groupMaterial[key]!),
          ],
        ),
    ],
  );
}

/// Material display order in a rail — plastics first (most of the catalog), then
/// metals; an unknown material sits between known and material-less, and the
/// material-less tiles ('') come LAST.
const List<String> _kMaterialOrder = [
  'PPR', 'רב-שכבתי', 'פקס', 'HDPE', 'PE', 'PVC', 'פוליאתילן',
  'נחושת', 'פליז', 'פלדה', 'נירוסטה', 'אלומיניום',
];

int _materialRank(String material) {
  if (material.isEmpty) return 1 << 20; // material-less → last
  final i = _kMaterialOrder.indexOf(material);
  return i < 0 ? 1 << 10 : i; // unknown → between known and material-less
}

/// Order a family's (material⋄type) group keys by material rank, STABLE within a
/// material (first-appearance / catalog order kept) — so the rail reads
/// PPR-tiles · HDPE-tiles · נחושת-tiles, grouped, as the owner asked.
List<String> _byMaterialThenType(
  List<String> keys,
  Map<String, String> groupMaterial,
) {
  final indexed = [for (var i = 0; i < keys.length; i++) (i, keys[i])]
    ..sort((a, b) {
      final ra = _materialRank(groupMaterial[a.$2]!);
      final rb = _materialRank(groupMaterial[b.$2]!);
      return ra != rb ? ra.compareTo(rb) : a.$1.compareTo(b.$1);
    });
  return [for (final e in indexed) e.$2];
}

/// One tile per (material × TYPE) group — label = the [typeWordOf]; sku from the
/// BRIGHTEST member ([_pickRep]); image = that photo unless genuinely black
/// ([_repImage] → null ⇒ the emoji); [material] tags the tile for rail paging.
ConfigTile _typeTile(List<LipskeyCatalogProduct> group, [String material = '']) {
  final rep = _pickRep(group);
  return ConfigTile(
    sku: rep.sku,
    nameHe: typeWordOf(rep),
    emoji: tileEmoji(rep.categoryEmoji),
    imageAsset: _repImage(rep),
    materialHe: material,
  );
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

/// A synthetic root over the ENTIRE catalog tree — the whole-catalog dive (owner:
/// run over ALL of `kCatalogTree` (~1,800 products), not just the pilot section).
/// [browseSection] walks its subtree → one open family per pictured leaf-category.
const CatalogNode kCatalogRootNode = CatalogNode(
  id: 'catalog-root',
  title: 'כל הקטלוג',
  emoji: '🗂️',
  children: kCatalogTree,
);
