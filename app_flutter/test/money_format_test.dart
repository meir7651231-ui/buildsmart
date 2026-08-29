// Pins the single-source ₪ grouper (#currency-single-source). Every ₪ display in
// the app routes through these, so the SAME amount renders identically on the
// catalog card, the cart, the manager dashboard, budget, finance and the
// contractor sheets — no more "₪4200" browsing vs "₪4,200" at checkout.
import 'package:buildsmart/logic/money_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('groupThousands — locale-free comma grouping over abs', () {
    test('groups every 3 digits from the right', () {
      expect(groupThousands(0), '0');
      expect(groupThousands(900), '900');
      expect(groupThousands(4200), '4,200'); // THE divergence case
      expect(groupThousands(50000), '50,000');
      expect(groupThousands(1234567), '1,234,567');
    });

    test('groups the ABSOLUTE value (sign is the caller\'s job)', () {
      expect(groupThousands(-4200), '4,200');
    });
  });

  group('formatNis — signed ₪ with grouping', () {
    test('positive → ₪ before the grouped digits', () {
      expect(formatNis(4200), '₪4,200');
      expect(formatNis(100), '₪100');
    });

    test('negative → sign BEFORE the ₪ (never "₪-")', () {
      expect(formatNis(-3150), '-₪3,150');
      expect(formatNis(-3150).contains('₪-'), isFalse);
    });

    test('prefix leads the whole token', () {
      expect(formatNis(4200, prefix: '~'), '~₪4,200');
    });
  });
}
