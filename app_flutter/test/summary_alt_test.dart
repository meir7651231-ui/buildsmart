// Roadmap step 59 (smartCardSummaryHe) + step 45 (cheaperAlternativeBrand).
import 'package:buildsmart/data/related_info.dart';
import 'package:buildsmart/data/smart_tree.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('smartCardSummaryHe', () {
    test('summary starts with product+brand name and never throws', () {
      for (final sp in kSmartProducts) {
        for (final b in sp.brands) {
          final s = smartCardSummaryHe(sp, b);
          expect(s, startsWith(sp.name));
          expect(s, contains(b.name));
          expect(s.split(' · ').length, greaterThanOrEqualTo(1));
        }
      }
    });

    test('summary includes a price marker when one is known', () {
      for (final sp in kSmartProducts) {
        for (final b in sp.brands) {
          if (b.price != null) {
            expect(smartCardSummaryHe(sp, b), contains('₪'),
                reason: '${sp.key}/${b.name}');
          }
        }
      }
    });
  });

  group('cheaperAlternativeBrand', () {
    test('out-of-range index returns null', () {
      final sp = kSmartProducts.first;
      expect(cheaperAlternativeBrand(sp, -1), isNull);
      expect(cheaperAlternativeBrand(sp, 9999), isNull);
    });

    test('when a cheaper priced sibling exists it is the strictly-cheapest one',
        () {
      for (final sp in kSmartProducts) {
        for (var i = 0; i < sp.brands.length; i++) {
          final sel = sp.brands[i];
          if (sel.price == null) {
            expect(cheaperAlternativeBrand(sp, i), isNull);
            continue;
          }
          final alt = cheaperAlternativeBrand(sp, i);
          // Compute expected min cheaper price independently.
          int? expected;
          for (var j = 0; j < sp.brands.length; j++) {
            if (j == i) continue;
            final p = sp.brands[j].price;
            if (p == null || p >= sel.price!) continue;
            if (expected == null || p < expected) expected = p;
          }
          if (expected == null) {
            expect(alt, isNull, reason: '${sp.key} idx $i');
          } else {
            expect(alt, isNotNull, reason: '${sp.key} idx $i');
            expect(alt!.price, expected);
            expect(alt.price, lessThan(sel.price!));
          }
        }
      }
    });
  });
}
