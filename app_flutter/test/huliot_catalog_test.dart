// Validation gate for the additive Huliot catalog (directive:
// knowledge/DIRECTIVE-huliot-images.md). The scrape's 1,346 SKUs were classified
// against the MATERIALIZED ~1,867-product catalog (not a regex): 557 already
// exist (390 Polyroll + 167 SmartLock) and are EXCLUDED here to stay additive;
// only the 789 genuinely-new SKUs are added. This proves the staging catalog is
// well-formed, truly additive (zero SKU overlap → no duplicates), that under the
// default flag the product UNIVERSE is unchanged (the 789 new products stay
// staged) while the owner's image upgrades are LIVE in v1, and that the
// compat/variant engines do not crash on Huliot products.

import 'package:buildsmart/data/catalog_source.dart';
import 'package:buildsmart/data/fitting_image_overrides.dart';
import 'package:buildsmart/data/huliot_catalog.dart';
import 'package:buildsmart/data/huliot_image_overrides.dart';
import 'package:buildsmart/data/lipski_image_overrides.dart';
import 'package:buildsmart/data/polyroll_catalog.dart' show kCatalogProducts;
import 'package:buildsmart/data/related_info.dart'
    show compatibleProductsFor, variantSiblingsOf;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Huliot catalog — additive staging (new-only)', () {
    test('789 new products; 784 with an owner-picked image, rest → emoji', () {
      expect(kHuliotProducts.length, 789);
      for (final p in kHuliotProducts) {
        expect(p.brand, 'Huliot');
        expect(p.sku.trim(), isNotEmpty);
        expect(p.nameHe.trim(), isNotEmpty);
        if (p.imageFile != null) {
          expect(p.imageFile!.endsWith('.jpeg'), isTrue);
        }
      }
      // owner's image-games: 784 got a real photo (714 first pass + 70 Ultra
      // Silent), 5 answered "none" → emoji.
      expect(kHuliotProducts.where((p) => p.imageFile != null).length, 784);
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

    test('v2 = v1 + 789 new; default source stays v1 (same universe)', () {
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

  group('owner image overrides (existing products) — LIVE in v1', () {
    test('784 overrides (512 huliot + 248 lipski + 24 fitting) LIVE in v1', () {
      expect(kHuliotImageOverrides.length, 512);
      expect(kLipskiImageOverrides.length, 248);
      // the maps are pairwise disjoint. Fitting only fills SKUs with NO earlier
      // owner pick (net-new), so it never overlaps huliot/lipski.
      expect(
        kHuliotImageOverrides.keys.toSet().intersection(
          kLipskiImageOverrides.keys.toSet(),
        ),
        isEmpty,
      );
      final fittingKeys = kFittingImageOverrides.keys.toSet();
      expect(fittingKeys.intersection(kHuliotImageOverrides.keys.toSet()), isEmpty);
      expect(fittingKeys.intersection(kLipskiImageOverrides.keys.toSet()), isEmpty);
      // v1 (the live catalog every consumer reads) carries ALL overrides —
      // applied at the source (polyroll_catalog.dart), so the good photos show
      // everywhere, not only behind CATALOG_SOURCE=v2.
      final v1Overridden = {
        for (final p in kCatalogProducts)
          if (p.imageAssetOverride != null) p.sku,
      };
      expect(
        v1Overridden.length,
        kHuliotImageOverrides.length +
            kLipskiImageOverrides.length +
            kFittingImageOverrides.length,
      );
      expect(v1Overridden, containsAll(kHuliotImageOverrides.keys));
      expect(v1Overridden, containsAll(kLipskiImageOverrides.keys));
      expect(v1Overridden, containsAll(kFittingImageOverrides.keys));
      // v2 inherits them (v2 = v1 + the 789 new products) — no extra overrides.
      final v2Overridden = {
        for (final p in kCatalogProductsV2)
          if (p.imageAssetOverride != null) p.sku,
      };
      expect(v2Overridden, v1Overridden);
    });

    test('overridden products resolve to the chosen image, brand kept', () {
      final hSku = kHuliotImageOverrides.keys.first;
      final hp = kCatalogProducts.firstWhere((e) => e.sku == hSku);
      expect(hp.imageAsset, kHuliotImageOverrides[hSku]);
      expect(hp.imageAsset, startsWith('assets/huliot/products/'));
      // brand identity is preserved — a Huliot-photo override can sit on a
      // פולירול/חוליות product; it is NOT rebranded to the image's directory.
      expect(hp.brand, isNotEmpty);
      expect(hp.brand, isNot('Huliot'));

      final lSku = kLipskiImageOverrides.keys.first;
      final lp = kCatalogProducts.firstWhere((e) => e.sku == lSku);
      expect(lp.imageAsset, kLipskiImageOverrides[lSku]);
      expect(lp.imageAsset, startsWith('assets/lipski_site/'));
      expect(lp.brand, isNotEmpty);
    });

    test('24 fitting overrides fill net-new SKUs (owner picks still win)', () {
      expect(kFittingImageOverrides.length, 24);
      final fSku = kFittingImageOverrides.keys.first;
      final fp = kCatalogProducts.firstWhere((e) => e.sku == fSku);
      // the fitting image is live on the product...
      expect(fp.imageAsset, kFittingImageOverrides[fSku]);
      expect(fp.imageAsset, startsWith('assets/huliot/products/'));
      // ...and brand identity is untouched (these are Polyroll fittings).
      expect(fp.brand, isNotEmpty);
      // precedence: any SKU that ALSO had a huliot pick keeps the huliot one.
      for (final s in kFittingImageOverrides.keys) {
        expect(kHuliotImageOverrides.containsKey(s), isFalse);
      }
    });
  });
}
