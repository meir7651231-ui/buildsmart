// Roadmap step 42 — lineCostEstimateFor. Pure cost breakdown.
import 'package:buildsmart/data/related_info.dart';
import 'package:buildsmart/data/smart_tree.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('out-of-range index returns null', () {
    final sp = kSmartProducts.first;
    expect(lineCostEstimateFor(sp, -1), isNull);
    expect(lineCostEstimateFor(sp, 999), isNull);
  });

  test('total equals product + accessories + labour, all non-negative', () {
    var priced = 0;
    for (final sp in kSmartProducts) {
      for (var i = 0; i < sp.brands.length; i++) {
        final c = lineCostEstimateFor(sp, i);
        if (c == null) continue;
        priced++;
        expect(c.product, greaterThanOrEqualTo(0));
        expect(c.accessories, greaterThanOrEqualTo(0));
        expect(c.labour, greaterThanOrEqualTo(0));
        expect(c.total, c.product + c.accessories + c.labour);
        expect(c.total, greaterThan(0));
      }
    }
    expect(priced, greaterThan(0));
  });

  test('accessories component matches the sum of mandatory accessory prices',
      () {
    for (final sp in kSmartProducts) {
      final expectedAcc = sp.acc
          .where((a) => a.must)
          .fold<int>(0, (s, a) => s + (a.price ?? 0));
      for (var i = 0; i < sp.brands.length; i++) {
        final c = lineCostEstimateFor(sp, i);
        if (c != null) {
          expect(c.accessories, expectedAcc, reason: sp.key);
        }
      }
    }
  });
}
