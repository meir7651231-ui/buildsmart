import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/screens/catalog_screen.dart';
import 'package:buildsmart/screens/store_screen.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Deep coverage of the pure state/logic helpers behind the cart & store:
/// cart-line display decomposition, order-open classification + seed, the
/// money math (VAT inclusive/exclusive, delivery, unit count), and the seeded
/// projects/orders providers.
void main() {
  group('cartLineDisplay', () {
    test('lipskey product → short type(+subtype) name, brand in attrs', () {
      final typed = kLipskeyCatalog.firstWhere((p) => p.productType != null);
      final line = SmartCartLine(
        productKey: 'lip:${typed.sku}',
        productName: typed.nameHe,
        productEmoji: '📦',
        brandName: 'מרינוביץ',
        brandPrice: 0,
        productQty: 1,
        accessories: const [],
      );
      final d = cartLineDisplay(line);
      final expectedName = [
        typed.productType!,
        if (typed.productSubtype != null) typed.productSubtype!,
      ].join(' ');
      expect(d.name, expectedName);
      expect(d.name.length, lessThanOrEqualTo(typed.nameHe.length));
      expect(d.attrs.contains('מרינוביץ'), isTrue,
          reason: 'supplier must appear in the attrs line');
    });

    test('unknown lip sku falls back to the line name + brand', () {
      const line = SmartCartLine(
        productKey: 'lip:____nope____',
        productName: 'שם מלא',
        productEmoji: '📦',
        brandName: 'מותג',
        brandPrice: 0,
        productQty: 1,
        accessories: [],
      );
      final d = cartLineDisplay(line);
      expect(d.name, 'שם מלא');
      expect(d.attrs, 'מותג');
    });

    test('non-lip (smart) key uses the line name + brand verbatim', () {
      const line = SmartCartLine(
        productKey: 'smart:basinTrap',
        productName: 'סיפון לכיור רחצה',
        productEmoji: '🌀',
        brandName: 'מותג',
        brandPrice: 50,
        productQty: 2,
        accessories: [],
      );
      final d = cartLineDisplay(line);
      expect(d.name, 'סיפון לכיור רחצה');
      expect(d.attrs, 'מותג');
    });
  });

  group('order-open classification', () {
    test('open until delivered', () {
      expect(isOrderOpen('preparing'), isTrue);
      expect(isOrderOpen('ready'), isTrue);
      expect(isOrderOpen('transit'), isTrue);
      expect(isOrderOpen(kDeliveredStage), isFalse);
    });

    test('seed orders expose exactly 3 open', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final open =
          c.read(storeOrdersProvider).where((o) => isOrderOpen(o.stage)).length;
      expect(open, 3);
    });
  });

  group('cart money math', () {
    test('VAT exclusive = 18% on top', () {
      expect(cartVat(1000, vatInclusive: false), 180);
      expect(cartTotal(1000, 45, vatInclusive: false), 1225);
    });

    test('VAT inclusive = embedded portion, total adds only delivery', () {
      expect(cartVat(1180, vatInclusive: true), 180); // 1180 - round(1180/1.18)
      expect(cartTotal(1180, 45, vatInclusive: true), 1225);
      expect(cartVat(100, vatInclusive: true), 15); // 100 - round(84.7)=85
    });

    test('delivery fees per method', () {
      expect(deliveryFeeFor(CartDelivery.express), 120);
      expect(deliveryFeeFor(CartDelivery.standard), 45);
      expect(deliveryFeeFor(CartDelivery.pickup), 0);
    });

    test('unit count sums fixed qtys + smart-line qtys (not lines)', () {
      const a = SmartCartLine(
        productKey: 'k1', productName: 'a', productEmoji: '📦',
        brandName: 'b', brandPrice: 1, productQty: 4, accessories: [],
      );
      const b = SmartCartLine(
        productKey: 'k2', productName: 'b', productEmoji: '📦',
        brandName: 'b', brandPrice: 1, productQty: 6, accessories: [],
      );
      // 3 fixed units (0 ignored) + 10 smart units = 13 (not 2 lines).
      expect(cartItemCount(const {'x': 3, 'y': 0}, const [a, b]), 13);
    });

    test('line.total includes accessories', () {
      const line = SmartCartLine(
        productKey: 'k', productName: 'p', productEmoji: '📦',
        brandName: 'b', brandPrice: 100, productQty: 3,
        accessories: [
          SmartCartAcc(name: 'x', emoji: '🔩', price: 20, qty: 2),
          SmartCartAcc(name: 'y', emoji: '🔩', price: 5, qty: 1),
        ],
      );
      expect(line.total, 100 * 3 + 20 * 2 + 5); // 345
    });
  });

  group('seeded providers', () {
    test('projects seed has the three defaults', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final projects = c.read(storeProjectsProvider);
      expect(projects, containsAll(<String>['בית דוד 3', 'מגדל עזריאלי', 'ללא פרויקט']));
    });
  });
}
