import 'package:buildsmart/screens/store_screen.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Regression coverage for the settings → behavior wiring added this cycle:
/// the smart-cart quantity stepper helpers and the store-settings cart defaults.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  SmartCartLine line(int qty, {String key = 'lip:SKU1'}) => SmartCartLine(
        productKey: key,
        productName: 'מוצר בדיקה',
        productEmoji: '🔩',
        brandName: 'BS',
        brandPrice: 0,
        productQty: qty,
        accessories: const [],
      );

  group('smart cart — qtyForKey / setQtyForKey (grid stepper)', () {
    test('qtyForKey sums all lines sharing a product key', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final cart = c.read(smartCartProvider.notifier)
        ..add(line(2))
        ..add(line(3))
        ..add(line(1, key: 'lip:OTHER'));
      expect(cart.qtyForKey('lip:SKU1'), 5);
      expect(cart.qtyForKey('lip:OTHER'), 1);
      expect(cart.qtyForKey('lip:MISSING'), 0);
    });

    test('setQtyForKey collapses a product to a single line', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final cart = c.read(smartCartProvider.notifier)
        ..add(line(2))
        ..add(line(3));
      cart.setQtyForKey(line(4));
      expect(cart.qtyForKey('lip:SKU1'), 4);
      expect(
        c.read(smartCartProvider).where((l) => l.productKey == 'lip:SKU1').length,
        1,
      );
    });

    test('setQtyForKey with qty <= 0 removes the product', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final cart = c.read(smartCartProvider.notifier)..add(line(3));
      cart.setQtyForKey(line(0));
      expect(cart.qtyForKey('lip:SKU1'), 0);
      expect(c.read(smartCartProvider), isEmpty);
    });
  });

  group('store settings — cart defaults wiring', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('default payment (card) seeds the cart payment method', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      // Default StorePayment.card → CartPaymentMethod.card.
      expect(c.read(cartPaymentProvider), CartPaymentMethod.card);
    });

    test('selfPickupDefault=false → cart delivery is standard, not pickup', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(cartDeliveryProvider), CartDelivery.standard);
    });
  });
}
