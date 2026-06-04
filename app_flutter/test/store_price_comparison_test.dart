// T2 DoD guard (PLAN-contractor-completion §T2): the catalog-⋮ "השוואת מחירים"
// scan compares each product across its partner stores and marks the cheapest.
// Prices are verbatim from kPlanTypes store offers (proto §9b) — no invention.
import 'package:buildsmart/screens/home_shell.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('store price comparison (T2)', () {
    final rows = storePriceComparisonAcrossCatalog();

    // DoD: "מציג ≥3 חנויות, הזול מודגש" — at least 3 products to compare.
    test('finds >=3 products to compare across stores', () {
      expect(rows.length, greaterThanOrEqualTo(3));
    });

    test('every row has >=3 stores; bestIndex marks the genuine cheapest', () {
      for (final r in rows) {
        expect(r.stores.length, greaterThanOrEqualTo(3));
        expect(r.bestIndex, inInclusiveRange(0, r.stores.length - 1));
        final minPrice =
            r.stores.map((s) => s.price).reduce((a, b) => a < b ? a : b);
        expect(r.best.price, minPrice,
            reason: 'the highlighted store must be the cheapest');
        expect(r.product, isNotEmpty);
        for (final s in r.stores) {
          expect(s.store, isNotEmpty);
          expect(s.price, greaterThan(0));
        }
      }
    });

    test('matches real proto §9b store prices (no invention)', () {
      // plumbing zone 1 — אסלה: בנייני העיר 789 · אבן קיסר 740 · טמבור הום 765.
      final toilet = rows.firstWhere(
        (r) =>
            r.stores.any((s) => s.store == 'בנייני העיר' && s.price == 789) &&
            r.stores.any((s) => s.store == 'טמבור הום' && s.price == 765),
        orElse: () => throw StateError('toilet store-row not found'),
      );
      expect(toilet.best.store, 'אבן קיסר');
      expect(toilet.best.price, 740);
    });
  });
}
