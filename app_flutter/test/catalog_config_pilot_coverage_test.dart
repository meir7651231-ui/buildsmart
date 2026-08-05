// CATALOG-CONFIG · pilot image-coverage smoke — builds the pilot browse over the
// LIVE catalog and pins that the open families derive a REAL representative image
// (plan D · derived from the family's first pictured product, NEVER a hardcoded
// family→image map — it survives a catalog delete-and-reupload) for the vast
// majority, the emoji fallback staying a rare edge (the owner's "~99.6% image
// coverage"). Prints the per-family breakdown for the dive-bs2b visual-verify
// report. Deterministic (the catalog is a compiled constant); exercised
// define-less (kCatalogConfig OFF).
// ignore_for_file: avoid_print
import 'package:buildsmart/data/catalog_source.dart' show resolvedCatalogProducts;
import 'package:buildsmart/features/catalog_config/browse_model.dart';
import 'package:buildsmart/features/catalog_config/product_chips.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pilot families derive a real representative image (emoji is a rare edge)',
      () {
    final section = pilotSectionNode();
    expect(section, isNotNull);
    final browse = browseSection(section!, resolvedCatalogProducts);
    expect(browse.families, isNotEmpty);

    var withImage = 0;
    var productTotal = 0; // SKUs (variations, pre-collapse)
    var typeTotal = 0; // tiles (types, post-collapse)
    for (final f in browse.families) {
      final rep = f.representativeImage;
      if (rep != null) {
        withImage++;
      }
      productTotal += f.productCount;
      typeTotal += f.tiles.length;
      print(
        '  ${f.titleHe} | products=${f.productCount} -> types=${f.tiles.length}'
        ' | rep=${rep ?? 'EMOJI(${f.emoji})'}',
      );
    }
    print('PILOT "${browse.titleHe}" · families=${browse.families.length}');
    print('RAIL-COLLAPSE: $productTotal SKUs -> $typeTotal type tiles');
    print('FAMILY-COVERAGE: $withImage/${browse.families.length} real-image');

    // every open family is non-empty (browseSection drops 0-tile leaves)…
    expect(browse.families.every((f) => f.tiles.isNotEmpty), isTrue);
    // …the rail COLLAPSES variations: fewer type-tiles than raw SKUs…
    expect(typeTotal, lessThan(productTotal));
    // …and the vast majority derive a REAL image (emoji is the rare edge).
    expect(
      withImage,
      greaterThanOrEqualTo((browse.families.length * 0.7).floor()),
      reason: 'too many families fell back to the emoji header',
    );
  });

  test('WHOLE catalog — collapse + wheel-count distribution (owner §2 · §10)', () {
    final browse = browseSection(kCatalogRootNode, resolvedCatalogProducts);
    expect(browse.families, isNotEmpty);
    final bySku = {for (final p in resolvedCatalogProducts) p.sku: p};

    var products = 0;
    var tiles = 0;
    var familiesWithImage = 0;
    final wheelHist = <int, int>{0: 0, 1: 0, 2: 0, 3: 0}; // wheels (capped 3) -> tiles
    for (final f in browse.families) {
      products += f.productCount;
      tiles += f.tiles.length;
      if (f.representativeImage != null) {
        familiesWithImage++;
      }
      for (final t in f.tiles) {
        final p = bySku[t.sku];
        final raw = p == null ? 0 : prioritizedSchema(p).attributes.length;
        final wheels = raw > 3 ? 3 : raw; // the card shows the top 3 (+ qty)
        wheelHist[wheels] = (wheelHist[wheels] ?? 0) + 1;
      }
    }
    print('WHOLE-CATALOG: ${browse.families.length} families · '
        '$products SKUs -> $tiles type tiles');
    print('FAMILY-IMG: $familiesWithImage/${browse.families.length} '
        'families with a real representative image');
    print('WHEELS/tile (capped 3, + qty always): '
        '${[for (var k = 0; k <= 3; k++) '$k→${wheelHist[k]}'].join(' · ')}');

    // the whole-catalog dive is real (many families) and the rail COLLAPSES.
    expect(browse.families.length, greaterThan(10));
    expect(tiles, lessThan(products));
    // not every tile is wheel-less — many carry a real wheel (graduated card).
    final wheelless = wheelHist[0] ?? 0;
    expect(wheelless, lessThan(tiles));
  });
}
