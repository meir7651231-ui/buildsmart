// Guard: catalog search SKU matching must not pollute numeric size queries.
//
// catalogProductMatchesQuery folds the SKU into the haystack so a user can
// find a product by its number. But matching the SKU as an arbitrary substring
// meant a short numeric size query ("20" / "200") also hit every product whose
// SKU merely *contained* those digits (e.g. "200" inside SKU 120011) — 55% of
// the results for "20" were unrelated SKU coincidences. SKU is now matched only
// for queries ≥5 chars (real SKUs are 5–10 digits); short size queries match
// name/category/colour only.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/screens/catalog_screen.dart';
import 'package:flutter_test/flutter_test.dart';

String _n(String s) =>
    s.toLowerCase().replaceAll('״', '"').replaceAll('׳', "'");

void main() {
  test('short numeric query never matches via SKU substring only', () {
    for (final q in ['20', '200', '50', '110', '3000']) {
      for (final p in kCatalogProducts) {
        if (!catalogProductMatchesQuery(p, q)) continue;
        final visible = _n('${p.nameHe} ${p.categoryHe} ${p.color ?? ''}');
        expect(
          visible.contains(q),
          isTrue,
          reason: 'q="$q" matched "${p.nameHe}" (sku=${p.sku}) only via SKU',
        );
      }
    }
  });

  test('a full SKU still finds its product', () {
    final p = kCatalogProducts.firstWhere((q) => q.sku.length >= 5);
    expect(
      catalogProductMatchesQuery(p, p.sku),
      isTrue,
      reason: 'the exact SKU ${p.sku} must match its product',
    );
    // a 5-char fragment of a long SKU still works
    if (p.sku.length >= 5) {
      expect(catalogProductMatchesQuery(p, p.sku.substring(0, 5)), isTrue);
    }
  });

  test('plain word search is unaffected', () {
    final taps = kCatalogProducts.where((p) => p.nameHe.contains('ברז'));
    expect(taps.every((p) => catalogProductMatchesQuery(p, 'ברז')), isTrue);
  });
}
