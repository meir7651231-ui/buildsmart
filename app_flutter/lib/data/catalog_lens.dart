// Catalog "lens" — the axis a product LIST is organised by (a list-level
// control that lives OUTSIDE the product card, beside the existing grid/list
// + sort controls). The same set of products can be presented through three
// lenses:
//   📂 category   — flat list by categoryHe (always available)
//   🎚 variant    — grouped into variant families (same product, varying size/
//                   color/model); available when the set has real families
//   🌳 smart-tree — only products that map to a SmartProduct fixture; available
//                   only when enough of the set maps (a raw-parts list like
//                   copper fittings or PPR would be near-empty here, so we hide
//                   the lens rather than show an almost-blank view — "approach א").
//
// This file is the PURE foundation (no UI, no providers). Tested by
// `catalog_lens_test.dart`. The UI selector + router are wired separately.

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/smart_tree.dart';
import 'package:buildsmart/data/variant_families.dart';

/// The three organising axes for a product list.
enum CatalogLens { category, variant, smartTree }

extension CatalogLensInfo on CatalogLens {
  /// Plain-Hebrew label for the selector chip.
  String get labelHe => switch (this) {
        CatalogLens.category => 'קטגוריה',
        CatalogLens.variant => 'וריאנטים',
        CatalogLens.smartTree => 'עץ חכם',
      };

  String get emoji => switch (this) {
        CatalogLens.category => '📂',
        CatalogLens.variant => '🎚',
        CatalogLens.smartTree => '🌳',
      };

  /// Combined "📂 קטגוריה" form for a chip.
  String get chipLabel => '$emoji $labelHe';
}

/// Minimum fraction of a product set that must map to a SmartProduct fixture
/// before the 🌳 smart-tree lens is offered. Below this the lens would be
/// near-empty (e.g. copper fittings ≈ 8%, PPR = 0%), so it's hidden.
/// Fixture-rich sets (the smart-tree section itself) are ≈100% → shown.
const double kSmartTreeLensMinFraction = 0.25;

/// The SKUs that belong to a *multi-member* variant family (size/color/model
/// siblings). Computed from [allVariantFamilies] (which is itself memoised).
/// Singletons are excluded — a family of one offers nothing to the variant lens.
Set<String> multiMemberFamilySkus() {
  final out = <String>{};
  for (final f in allVariantFamilies()) {
    if (f.products.length > 1) {
      for (final p in f.products) {
        out.add(p.sku);
      }
    }
  }
  return out;
}

/// Which lenses are meaningful for [products]:
///   • [CatalogLens.category]  — ALWAYS (every product has a categoryHe).
///   • [CatalogLens.variant]   — when ≥1 product is in a multi-member family.
///   • [CatalogLens.smartTree] — when the mapped fraction ≥ [smartTreeMinFraction].
///
/// [variantFamilySkus] can be injected (tests / caching); defaults to
/// [multiMemberFamilySkus]. An empty [products] yields just `[category]`.
///
/// Order is stable: category, variant, smartTree — the order the selector
/// chips appear left-to-right.
List<CatalogLens> availableLensesForSet(
  List<LipskeyCatalogProduct> products, {
  Set<String>? variantFamilySkus,
  double smartTreeMinFraction = kSmartTreeLensMinFraction,
}) {
  if (products.isEmpty) return const [CatalogLens.category];

  final out = <CatalogLens>[CatalogLens.category];

  final famSkus = variantFamilySkus ?? multiMemberFamilySkus();
  if (products.any((p) => famSkus.contains(p.sku))) {
    out.add(CatalogLens.variant);
  }

  final mapped =
      products.where((p) => smartProductForSku(p.sku) != null).length;
  if (mapped / products.length >= smartTreeMinFraction) {
    out.add(CatalogLens.smartTree);
  }

  return out;
}

/// True when [lens] is meaningful for [products]. Thin wrapper over
/// [availableLensesForSet] for single-lens checks (e.g. greying a chip).
bool setSupportsLens(
  List<LipskeyCatalogProduct> products,
  CatalogLens lens, {
  Set<String>? variantFamilySkus,
  double smartTreeMinFraction = kSmartTreeLensMinFraction,
}) =>
    availableLensesForSet(
      products,
      variantFamilySkus: variantFamilySkus,
      smartTreeMinFraction: smartTreeMinFraction,
    ).contains(lens);

/// One section of a lens-organised product list — a titled bucket.
/// (category → one per categoryHe · variant → one per family frame ·
/// smartTree → one per fixture name.)
class LensGroup {
  const LensGroup({required this.title, required this.products});

  final String title;
  final List<LipskeyCatalogProduct> products;

  int get count => products.length;
}

/// Re-organise [products] by [lens] into titled groups, preserving first-seen
/// order. PURE (no UI). The UI renders each group as a section header + rows.
///
///   • category  — bucket by `categoryHe`.
///   • variant   — bucket by multi-member variant family (frame = title); a
///                 product in no family becomes its own 1-member group
///                 (title = its name) so nothing is dropped.
///   • smartTree — keep ONLY products that map to a SmartProduct fixture,
///                 bucket by fixture name. Unmapped products are dropped (the
///                 lens is hidden by [availableLensesForSet] when too few map,
///                 so a visible smart-tree lens always has content).
List<LensGroup> groupByLens(
  List<LipskeyCatalogProduct> products,
  CatalogLens lens,
) {
  switch (lens) {
    case CatalogLens.category:
      return _bucketBy(products, (p) => p.categoryHe);

    case CatalogLens.variant:
      final skuToFrame = <String, String>{};
      for (final f in allVariantFamilies()) {
        if (f.products.length > 1) {
          for (final p in f.products) {
            skuToFrame[p.sku] = f.frame;
          }
        }
      }
      final byFrame = <String, List<LipskeyCatalogProduct>>{};
      final frameOrder = <String>[];
      final singletons = <LensGroup>[];
      for (final p in products) {
        final frame = skuToFrame[p.sku];
        if (frame == null) {
          singletons.add(LensGroup(title: p.nameHe, products: [p]));
        } else {
          if (!byFrame.containsKey(frame)) frameOrder.add(frame);
          byFrame.putIfAbsent(frame, () => []).add(p);
        }
      }
      // Multi-member families first (the useful groupings), then singletons.
      return [
        for (final frame in frameOrder)
          LensGroup(title: frame, products: byFrame[frame]!),
        ...singletons,
      ];

    case CatalogLens.smartTree:
      final byFixture = <String, List<LipskeyCatalogProduct>>{};
      final order = <String>[];
      for (final p in products) {
        final sp = smartProductForSku(p.sku);
        if (sp == null) continue; // unmapped → dropped from this lens
        if (!byFixture.containsKey(sp.name)) order.add(sp.name);
        byFixture.putIfAbsent(sp.name, () => []).add(p);
      }
      return [
        for (final name in order)
          LensGroup(title: name, products: byFixture[name]!),
      ];
  }
}

/// Bucket [products] by [keyOf], preserving first-seen key order.
List<LensGroup> _bucketBy(
  List<LipskeyCatalogProduct> products,
  String Function(LipskeyCatalogProduct) keyOf,
) {
  final map = <String, List<LipskeyCatalogProduct>>{};
  final order = <String>[];
  for (final p in products) {
    final k = keyOf(p);
    if (!map.containsKey(k)) order.add(k);
    map.putIfAbsent(k, () => []).add(p);
  }
  return [for (final k in order) LensGroup(title: k, products: map[k]!)];
}
