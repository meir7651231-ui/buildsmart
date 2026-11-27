import 'package:buildsmart/data/repositories/firestore_cached_repo.dart';
import 'package:buildsmart/data/repositories/orders_firebase.dart';
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

    // Nightly 2026-11-27 — toDoc wrote customerEmail but fromDoc never read it
    // back, so every Firestore snapshot rebuilt the order with ''.
    test('customerEmail survives the Firestore toDoc → fromDoc round-trip', () {
      final repo = FirebaseOrdersRepository();
      final o = base(customerEmail: 'buyer@example.com');
      final back = repo.fromDoc(RemoteDoc(o.id, repo.toDoc(o)));
      expect(back.customerEmail, 'buyer@example.com');
      expect(repo.fromDoc(RemoteDoc('BS-2', repo.toDoc(base()))).customerEmail, '');
    });

    test('copyWith preserves customerEmail', () {
      expect(
        base(customerEmail: 'a@b.co').copyWith(customerPhone: '050').customerEmail,
        'a@b.co',
      );
    });
  });
}
