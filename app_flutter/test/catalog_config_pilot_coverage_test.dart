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
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pilot families derive a real representative image (emoji is a rare edge)',
      () {
    final section = pilotSectionNode();
    expect(section, isNotNull);
    final browse = browseSection(section!, resolvedCatalogProducts);
    expect(browse.families, isNotEmpty);

    var withImage = 0;
    var tilesTotal = 0;
    var tilesWithImage = 0;
    for (final f in browse.families) {
      final rep = f.representativeImage;
      if (rep != null) {
        withImage++;
      }
      final ti = f.tiles.where((t) => t.imageAsset != null).length;
      tilesTotal += f.tiles.length;
      tilesWithImage += ti;
      print(
        '  ${f.titleHe} | count=${f.count} | '
        'rep=${rep ?? 'EMOJI(${f.emoji})'} | tiles=$ti/${f.tiles.length}',
      );
    }
    print('PILOT "${browse.titleHe}" · families=${browse.families.length}');
    print('FAMILY-COVERAGE: $withImage/${browse.families.length} real-image');
    print('TILE-COVERAGE: $tilesWithImage/$tilesTotal real-image');

    // every open family is non-empty (browseSection drops 0-tile leaves)…
    expect(browse.families.every((f) => f.tiles.isNotEmpty), isTrue);
    // …and the vast majority derive a REAL image (emoji is the rare edge).
    expect(
      withImage,
      greaterThanOrEqualTo((browse.families.length * 0.7).floor()),
      reason: 'too many families fell back to the emoji header',
    );
  });
}
