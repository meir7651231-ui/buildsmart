import 'package:buildsmart/screens/chats_screen.dart';
import 'package:buildsmart/screens/notifications_screen.dart';
import 'package:buildsmart/screens/store_screen.dart';
import 'package:buildsmart/state/notif_settings.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Executable WIRING CONTRACT — every wired button/setting added this cycle is
/// asserted here so the full `flutter test` regression enforces the contract.
/// Mirror of app_flutter/WIRING.md (keep both in sync).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  SmartCartLine line(int qty, {String key = 'lip:SKU1'}) => SmartCartLine(
        productKey: key,
        productName: 'מוצר בדיקה',
        productEmoji: '🔩',
        brandName: 'BS',
        brandPrice: 0,
        productQty: qty,
        accessories: const [],
      );

  group('CONTRACT · store grid — cart stepper', () {
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

    test('setQtyForKey collapses a product to one line', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final cart = c.read(smartCartProvider.notifier)
        ..add(line(2))
        ..add(line(3));
      cart.setQtyForKey(line(4));
      expect(cart.qtyForKey('lip:SKU1'), 4);
      expect(
        c
            .read(smartCartProvider)
            .where((l) => l.productKey == 'lip:SKU1')
            .length,
        1,
      );
    });

    test('setQtyForKey with qty <= 0 removes the product', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final cart = c.read(smartCartProvider.notifier)..add(line(3));
      cart.setQtyForKey(line(0));
      expect(c.read(smartCartProvider), isEmpty);
    });
  });

  group('CONTRACT · store settings → cart defaults', () {
    test('defaultPayment (card) seeds cart payment method', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(cartPaymentProvider), CartPaymentMethod.card);
    });

    test('selfPickupDefault=false keeps delivery on standard', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      expect(c.read(cartDeliveryProvider), CartDelivery.standard);
    });
  });

  group('CONTRACT · notifications — per-type filter', () {
    test('all types enabled → nothing muted', () {
      expect(notifMutedSections(NotifSettings.defaults), isEmpty);
    });

    test('disabling a type mutes its matching section', () {
      final s = NotifSettings.defaults.copyWith(
        typeOrders: false,
        typeShipments: false,
        typeDeals: false,
        typePriceDrops: false,
      );
      expect(
        notifMutedSections(s),
        {
          NotifSection.orders,
          NotifSection.shipments,
          NotifSection.deals,
          NotifSection.budget,
        },
      );
    });
  });

  group('CONTRACT · chats — mute / archive', () {
    test('mute-all sets every thread; clearing unmutes', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final muted = c.read(chatMutedIdsProvider.notifier);
      muted.setAll({'t1', 't2', 't3'});
      expect(c.read(chatMutedIdsProvider), {'t1', 't2', 't3'});
      muted.setAll(<String>{});
      expect(c.read(chatMutedIdsProvider), isEmpty);
    });

    test('archive adds, restore removes', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final arch = c.read(chatArchivedIdsProvider.notifier)..archive('t1');
      expect(c.read(chatArchivedIdsProvider), contains('t1'));
      arch.restore('t1');
      expect(c.read(chatArchivedIdsProvider), isNot(contains('t1')));
    });
  });
}
