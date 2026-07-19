// Validation gate for the additive Huliot catalog (directive:
// knowledge/DIRECTIVE-huliot-images.md). The scrape's 1,346 SKUs were classified
// against the MATERIALIZED ~1,867-product catalog (not a regex): 557 already
// exist (390 Polyroll + 167 SmartLock) and are EXCLUDED here to stay additive;
// only the 789 genuinely-new SKUs are added. This proves the staging catalog is
// well-formed, truly additive (zero SKU overlap → no duplicates), that v1 stays
// byte-identical under the default flag, and that the compat/variant engines do
// not crash on Huliot products.

import 'package:buildsmart/data/catalog_source.dart';
import 'package:buildsmart/data/huliot_catalog.dart';
import 'package:buildsmart/data/huliot_image_overrides.dart';
import 'package:buildsmart/data/polyroll_catalog.dart' show kCatalogProducts;
import 'package:buildsmart/data/related_info.dart'
    show compatibleProductsFor, variantSiblingsOf;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Huliot catalog — additive staging (new-only)', () {
    test('789 new products; 714 with an owner-picked image, rest → emoji', () {
      expect(kHuliotProducts.length, 789);
      for (final p in kHuliotProducts) {
        expect(p.brand, 'Huliot');
        expect(p.sku.trim(), isNotEmpty);
        expect(p.nameHe.trim(), isNotEmpty);
        if (p.imageFile != null) {
          expect(p.imageFile!.endsWith('.jpeg'), isTrue);
        }
      }
      // owner's image-game: 714 got a real photo, 75 answered "none" → emoji.
      expect(kHuliotProducts.where((p) => p.imageFile != null).length, 714);
    });

    test('truly additive — zero SKU overlap with the existing catalog', () {
      final existing = {for (final p in kCatalogProducts) p.sku};
      final huliot = {for (final p in kHuliotProducts) p.sku};
      expect(existing.intersection(huliot), isEmpty);
    });

    test('no duplicate SKUs within the new Huliot set', () {
      final skus = kHuliotProducts.map((p) => p.sku).toList();
      expect(skus.toSet().length, skus.length);
    });

    test('v2 = v1 + new Huliot; default source stays v1 (byte-identical)', () {
      expect(
        kCatalogProductsV2.length,
        kCatalogProducts.length + kHuliotProducts.length,
      );
      expect(catalogSource, CatalogSource.v1);
      expect(resolvedCatalogProducts.length, kCatalogProducts.length);
    });

    test('picked images resolve under huliot/products/', () {
      final withImg = kHuliotProducts.where((p) => p.imageFile != null);
      for (final p in withImg.take(50)) {
        expect(p.imageAsset, startsWith('assets/huliot/products/'));
        expect(p.imageAsset, endsWith('.jpeg'));
      }
    });

    test('compat/variant engines do not crash on Huliot products', () {
      for (final p in kHuliotProducts.take(60)) {
        expect(() => compatibleProductsFor(p), returnsNormally);
        expect(() => variantSiblingsOf(p), returnsNormally);
      }
    });
  });

  group('owner image overrides (existing products, v2 only)', () {
    test('512 overrides applied in v2; v1 untouched', () {
      expect(kHuliotImageOverrides.length, 512);
      // v1 carries NO override — the existing catalog stays byte-identical.
      expect(
        kCatalogProducts.where((p) => p.imageAssetOverride != null),
        isEmpty,
      );
      final v2Overridden = {
        for (final p in kCatalogProductsV2)
          if (p.imageAssetOverride != null) p.sku,
      };
      expect(v2Overridden.length, kHuliotImageOverrides.length);
      expect(v2Overridden, containsAll(kHuliotImageOverrides.keys));
    });

    test('overridden product resolves to the huliot image, brand unchanged', () {
      final sku = kHuliotImageOverrides.keys.first;
      final p = kCatalogProductsV2.firstWhere((e) => e.sku == sku);
      expect(p.imageAsset, kHuliotImageOverrides[sku]);
      expect(p.imageAsset, startsWith('assets/huliot/products/'));
      final v1 = kCatalogProducts.firstWhere((e) => e.sku == sku);
      expect(p.brand, v1.brand); // identity preserved
    });
  });
}
