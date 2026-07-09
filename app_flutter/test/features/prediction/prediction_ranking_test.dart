// Unit tests for the pure prediction-ranking tie-breakers (nameAffinity +
// productProminence). The aggregate LIFT is proven by prediction_baseline_test;
// these pin the per-function invariants that make it non-zero-sum.

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/features/global_search/prediction_ranking.dart';
import 'package:flutter_test/flutter_test.dart';

LipskeyCatalogProduct _p(String name,
        {String sku = 'X', String? img, int page = 100}) =>
    LipskeyCatalogProduct(
      sku: sku,
      nameHe: name,
      nameEn: name,
      categoryHe: 'c',
      categoryEn: 'c',
      categoryEmoji: '🔧',
      page: page,
      imageFile: img,
    );

void main() {
  group('nameAffinity', () {
    test('exact name > prefix > mere-embed > unrelated (the buried-product fix)',
        () {
      final exact = nameAffinity(_p('ברז'), 'ברז');
      final prefix = nameAffinity(_p('ברז כדורי'), 'ברז');
      final embed = nameAffinity(_p('מחבר עם ברז ניל ואטם'), 'ברז');
      expect(exact, greaterThan(prefix),
          reason: 'a product whose name IS the query must lead');
      expect(prefix, greaterThan(embed),
          reason: 'a prefix match beats one that merely embeds the query');
      expect(nameAffinity(_p('אסלה תלויה'), 'ברז'), 0,
          reason: 'query not in the name → no affinity');
    });

    test('deterministic; empty query → 0', () {
      expect(nameAffinity(_p('ברז'), 'ברז'), nameAffinity(_p('ברז'), 'ברז'));
      expect(nameAffinity(_p('ברז'), ''), 0);
    });
  });

  group('productProminence', () {
    test('a showcased (imaged) product outranks its image-less twin', () {
      expect(productProminence(_p('ברז', img: 'brz.png')),
          greaterThan(productProminence(_p('ברז'))));
    });

    test('a short/generic name outranks a long specific one', () {
      expect(productProminence(_p('ברז')),
          greaterThan(productProminence(_p('ברז מעבר כדורי גדול חזק מאוד ניל'))));
    });

    test('deterministic', () {
      expect(productProminence(_p('ברז')), productProminence(_p('ברז')));
    });
  });
}
