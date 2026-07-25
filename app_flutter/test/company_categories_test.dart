// Derived-categories contract (clean-100 slice): the browse rows of a
// COMPANY catalog are the catalog's own categories — first-appearance order,
// dedup, emoji from the first product ('📦' template default when absent),
// counts in the tree's '$count מוצרים' idiom. Pure functions over an
// injected list — fully provable define-less.

import 'package:buildsmart/data/company_categories.dart';
import 'package:buildsmart/data/lipskey_catalog.dart'
    show LipskeyCatalogProduct;
import 'package:flutter_test/flutter_test.dart';

LipskeyCatalogProduct _p(String sku, String cat, {String emoji = ''}) =>
    LipskeyCatalogProduct(
      sku: sku,
      nameHe: 'מוצר $sku',
      nameEn: '',
      categoryHe: cat,
      categoryEn: '',
      categoryEmoji: emoji,
      page: 0,
      brand: '',
    );

void main() {
  group('companyCategorySections', () {
    test('first-appearance order + dedup (the company file IS the taxonomy)',
        () {
      final s = companyCategorySections([
        _p('A1', 'ברזים', emoji: '🚰'),
        _p('A2', 'כיורים'),
        _p('A3', 'ברזים'),
        _p('A4', 'אביזרי אמבט', emoji: '🛁'),
      ]);
      expect(s.map((x) => x.title).toList(), ['ברזים', 'כיורים', 'אביזרי אמבט']);
      expect(s[0].emoji, '🚰');
      expect(s[1].emoji, '📦', reason: 'empty cell → the template default');
      expect(s[0].id, 'company.ברזים');
    });

    test('empty list / empty categories → no rows (honest blank)', () {
      expect(companyCategorySections(const []), isEmpty);
      expect(companyCategorySections([_p('A1', '')]), isEmpty);
    });
  });

  group('companyCategorySummaries', () {
    test('counts per category, tree-idiom desc', () {
      final m = companyCategorySummaries([
        _p('A1', 'ברזים'),
        _p('A2', 'ברזים'),
        _p('A3', 'כיורים'),
      ]);
      expect(m['ברזים'], (count: 2, desc: '2 מוצרים'));
      expect(m['כיורים'], (count: 1, desc: '1 מוצרים'));
      expect(m.containsKey(''), isFalse);
    });
  });
}
