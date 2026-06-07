// T1 DoD guard (PLAN-contractor-completion §T1): the catalog-⋮ "חלופות זולות"
// scan finds real cheaper same-product alternatives from kHomeProductBrands
// (the sheet renders these). Verbatim from proto §1b HOME_PRODUCTS price tiers.
import 'package:buildsmart/screens/contractor_tools_sheets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cheaper alternatives — >=3 products with real savings, sorted', () {
    final alts = cheaperAlternativesAcrossCatalog();

    // DoD: "בדיקה ל-3 מוצרים" — at least 3 products carry a cheaper alternative.
    expect(alts.length, greaterThanOrEqualTo(3),
        reason: 'expected >=3 smart-tree products with a cheaper brand');

    for (final a in alts) {
      expect(a.altPrice, lessThan(a.recPrice),
          reason: 'the alternative must be cheaper than the recommendation');
      expect(a.savings, a.recPrice - a.altPrice);
      expect(a.product, isNotEmpty);
      expect(a.recName, isNotEmpty);
      expect(a.altName, isNotEmpty);
    }

    // Sorted by savings, largest first (the sheet shows the best deals on top).
    for (var i = 1; i < alts.length; i++) {
      expect(alts[i - 1].savings, greaterThanOrEqualTo(alts[i].savings));
    }
  });
}
