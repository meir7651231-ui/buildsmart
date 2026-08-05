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
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/features/catalog_config/browse_model.dart';
import 'package:buildsmart/features/catalog_config/catalog_taxonomy.dart';
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

  test('WHOLE catalog via browseAll — 12 clean families + wheel distribution (owner §1·§2·§10)', () {
    // ── (1) FAMILIES — the fragmented 93 leaves fold into the 12 CLEAN owner groups
    //    ([familyGroupOf]); every product lands in exactly one, and the rail collapses
    //    the SKUs into TYPE tiles ([typeWordOf], the canonical word).
    final browse = browseAll(resolvedCatalogProducts);
    expect(browse.titleHe, 'כל הקטלוג');
    expect(browse.families.length, 12); // owner §1 — from 93 fragmented leaves
    expect(browse.families.every((f) => f.tiles.isNotEmpty), isTrue);
    final famProducts = browse.families.fold(0, (s, f) => s + f.productCount);
    expect(famProducts, resolvedCatalogProducts.length); // every product placed once
    final tiles = browse.families.fold(0, (s, f) => s + f.tiles.length);
    expect(tiles, lessThan(resolvedCatalogProducts.length)); // rail COLLAPSES

    // ── (2) WHEEL DISTRIBUTION — the card shows min(roster, 3) wheels (+ qty). Weight
    //    by the PRODUCTS a browser actually reaches: a type stands for its peer count.
    final repByType = <String, LipskeyCatalogProduct>{};
    final peers = <String, int>{};
    for (final p in resolvedCatalogProducts) {
      repByType.putIfAbsent(typeKeyOf(p), () => p);
      peers[typeKeyOf(p)] = (peers[typeKeyOf(p)] ?? 0) + 1;
    }
    final cardByProduct = <int, int>{0: 0, 1: 0, 2: 0, 3: 0}; // card wheels -> products
    for (final e in repByType.entries) {
      final roster = chipRoster(e.value).length;
      final card = roster > 3 ? 3 : roster;
      cardByProduct[card] = cardByProduct[card]! + peers[e.key]!;
    }
    final total = resolvedCatalogProducts.length;
    final mid = cardByProduct[2]! + cardByProduct[3]!;

    print('FAMILIES: ${browse.families.length} (from 93 fragmented leaves) · '
        '$total products -> $tiles type tiles');
    for (final f in browse.families) {
      print('  ${f.titleHe}: ${f.tiles.length} types · ${f.productCount} products');
    }
    print('CARD WHEELS by product exposure: '
        '${[for (var k = 0; k <= 3; k++) '$k→${cardByProduct[k]}'].join(' · ')}');
    print('2-3 wheels: ${(100 * mid / total).round()}% of products '
        '(owner §10: most 2-3, not 0-1)');

    // owner §10 — MOST products (by browsing exposure) land on a 2-3 wheel card.
    expect(mid, greaterThan(total * 0.6));
  });
}
