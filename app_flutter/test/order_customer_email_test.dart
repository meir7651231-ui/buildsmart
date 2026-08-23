import 'package:buildsmart/state/orders_engine.dart';
import 'package:flutter_test/flutter_test.dart';

// Guards the order-confirmation-email plumbing (SSOT: DIRECTIVE-order-
// confirmation-email). The buyer email must round-trip through the Order model
// so the Cloud Function (orderEmail.ts) can read it off the Firestore doc — and
// must stay ABSENT when never set (kOrderEmail off ⇒ byte-identical order doc).
void main() {
  group('order customerEmail plumbing', () {
    Order base({String customerEmail = ''}) => Order(
          id: 'BS-1',
          who: 'קבלן',
          site: '',
          items: 1,
          sum: 10,
          stage: 'new',
          customerEmail: customerEmail,
        );

    test('customerEmail survives toJson → fromJson', () {
      final round = Order.fromJson(base(customerEmail: 'buyer@example.com').toJson());
      expect(round.customerEmail, 'buyer@example.com');
    });

    test('absent customerEmail is NOT written (byte-identical order doc)', () {
      final o = base();
      expect(o.customerEmail, '');
      expect(o.toJson().containsKey('customerEmail'), isFalse);
    });

    test('copyWith preserves customerEmail', () {
      expect(
        base(customerEmail: 'a@b.co').copyWith(customerPhone: '050').customerEmail,
        'a@b.co',
      );
    });
  });
}
