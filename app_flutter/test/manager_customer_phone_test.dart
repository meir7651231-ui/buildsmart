import 'package:buildsmart/logic/manager_dashboard.dart';
import 'package:flutter_test/flutter_test.dart';

// #8/3c — the customer phone carried onto the ManagerCustomer aggregate (the key
// the manager's chat affordance resolves customer→uid on, else falls back to
// 📞/💬). Pure model guards: the field defaults empty (byte-identical when
// unknown) and copyWith stamps AND preserves it.
void main() {
  ManagerCustomer base() => ManagerCustomer(
        name: 'גבי',
        orderCount: 3,
        totalSpend: 450,
        creditLimit: 1000,
      );

  group('#8/3c ManagerCustomer.phone', () {
    test('defaults to empty (byte-identical when unknown)', () {
      expect(base().phone, '');
    });

    test('copyWith stamps the phone, preserves the rest', () {
      final c = base().copyWith(phone: '0501234567');
      expect(c.phone, '0501234567');
      expect(c.name, 'גבי');
      expect(c.orderCount, 3);
      expect(c.totalSpend, 450);
      expect(c.creditLimit, 1000);
    });

    test('copyWith WITHOUT phone preserves the existing phone', () {
      final c = base().copyWith(phone: '050').copyWith(totalSpend: 999);
      expect(c.phone, '050', reason: 'a later copyWith must not wipe the phone');
      expect(c.totalSpend, 999);
    });
  });
}
