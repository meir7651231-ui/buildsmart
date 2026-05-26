import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/screens/notifications_screen.dart';
import 'package:buildsmart/screens/store_screen.dart';
import 'package:buildsmart/state/catalog_settings.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/state/store_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Closes the 18 coverage gaps found by mutation testing: cart math, checkout
/// gates, notification filter/grouping, index tokenizer, and untested defaults.
void main() {
  group('store cart math', () {
    test('delivery fees are exact', () {
      expect(deliveryFeeFor(CartDelivery.express), 120);
      expect(deliveryFeeFor(CartDelivery.standard), 45);
      expect(deliveryFeeFor(CartDelivery.pickup), 0);
    });
    test('VAT exclusive = 18% on top', () {
      expect(cartVat(1000, vatInclusive: false), 180);
    });
    test('VAT inclusive = embedded 18% portion', () {
      expect(cartVat(1180, vatInclusive: true), 180);
    });
    test('VAT rounds (not floors)', () {
      // 1005 * 0.18 = 180.9 → 181 rounded, 180 floored.
      expect(cartVat(1005, vatInclusive: false), 181);
    });
    test('exclusive total adds VAT + delivery', () {
      expect(cartTotal(1000, 45, vatInclusive: false), 1225);
    });
    test('inclusive total is subtotal + delivery only', () {
      expect(cartTotal(1180, 45, vatInclusive: true), 1225);
    });
  });

  group('store checkout gates', () {
    StoreSettings s({int min = 0, int big = 5000, bool confirm = true}) =>
        StoreSettings.defaults.copyWith(
          minOrderAmount: min,
          largeOrderThreshold: big,
          confirmLargeOrder: confirm,
        );
    test('below-minimum is strict (< not <=)', () {
      expect(cartBelowMinimum(100, s(min: 100)), isFalse); // equal is allowed
      expect(cartBelowMinimum(99, s(min: 100)), isTrue);
      expect(cartBelowMinimum(50, s(min: 0)), isFalse); // 0 disables
      // min==0 must fully disable the gate even for a negative subtotal —
      // pins the `minOrderAmount > 0` guard (not `>= 0`).
      expect(cartBelowMinimum(-1, s(min: 0)), isFalse);
    });
    test('large-order confirm fires at the threshold (>= not >)', () {
      expect(cartNeedsLargeConfirm(100, s(big: 100)), isTrue); // equal triggers
      expect(cartNeedsLargeConfirm(99, s(big: 100)), isFalse);
      expect(
        cartNeedsLargeConfirm(9999, s(big: 100, confirm: false)),
        isFalse,
      );
    });
  });

  group('notification predicate + grouping', () {
    test('section filter hides other types, keeps "all"', () {
      expect(
        notifPasses(
          type: NotifSection.orders,
          title: 'x',
          preview: 'y',
          dismissed: false,
          section: NotifSection.shipments,
          query: '',
          muted: const {},
        ),
        isFalse,
      );
      expect(
        notifPasses(
          type: NotifSection.orders,
          title: 'x',
          preview: 'y',
          dismissed: false,
          section: NotifSection.all,
          query: '',
          muted: const {},
        ),
        isTrue,
      );
    });
    test('query matches title OR preview (not AND)', () {
      // matches title only — must still pass (AND-of-negatives logic)
      expect(
        notifPasses(
          type: NotifSection.orders,
          title: 'ברז כדורי',
          preview: 'xyz',
          dismissed: false,
          section: NotifSection.all,
          query: 'ברז',
          muted: const {},
        ),
        isTrue,
      );
    });
    test('muted type and dismissed are hidden', () {
      expect(
        notifPasses(
          type: NotifSection.deals,
          title: 'x',
          preview: 'y',
          dismissed: false,
          section: NotifSection.all,
          query: '',
          muted: const {NotifSection.deals},
        ),
        isFalse,
      );
    });
    test('collapse boundary is exactly 3', () {
      expect(shouldCollapseNotifRun(2), isFalse);
      expect(shouldCollapseNotifRun(3), isTrue);
      expect(shouldCollapseNotifRun(4), isTrue);
    });
  });

  group('search index tokenizer', () {
    test('indexable boundary is exactly 2 chars', () {
      expect(indexableWord('א'), isFalse);
      expect(indexableWord('אב'), isTrue);
      expect(indexableWord('אבג'), isTrue);
    });
    test('no index key is shorter than 2 chars', () {
      expect(lipskeyWordIndex().keys.every((k) => k.length >= 2), isTrue);
    });
  });

  group('catalog default constants', () {
    const d = CatalogSettings.defaults;
    test('grid columns default is 2', () => expect(d.gridColumns, 2));
    test('search radius default is 50', () => expect(d.searchRadius, 50));
    test('max distance default is 100', () => expect(d.maxDistance, 100));
    test('min rating default is any',
        () => expect(d.minRating, CatalogMinRating.any));
    test('image size default is medium',
        () => expect(d.imageSize, CatalogImageSize.medium));
    test('search history default on', () => expect(d.searchHistoryEnabled, isTrue));
    test('compact mode default off', () => expect(d.compactMode, isFalse));
  });

  group('cart line total + remove', () {
    test('line total = brand*qty + sum(acc.price*acc.qty)', () {
      const line = SmartCartLine(
        productKey: 'k',
        productName: 'p',
        productEmoji: '',
        brandName: 'b',
        brandPrice: 10,
        productQty: 3,
        accessories: [SmartCartAcc(name: 'a', emoji: '', price: 5, qty: 2)],
      );
      expect(line.total, 10 * 3 + 5 * 2); // 40
    });
    test('remove(index) drops exactly that line, keeps the others', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      SmartCartLine ln(String k) => SmartCartLine(
            productKey: k,
            productName: k,
            productEmoji: '',
            brandName: 'b',
            brandPrice: 0,
            productQty: 1,
            accessories: const [],
          );
      final n = c.read(smartCartProvider.notifier)
        ..add(ln('a'))
        ..add(ln('b'))
        ..add(ln('c'));
      n.remove(1);
      expect(
        c.read(smartCartProvider).map((l) => l.productKey).toList(),
        ['a', 'c'],
      );
    });
  });

  group('store payment / delivery mapping', () {
    test('payment maps every StorePayment value', () {
      expect(cartPaymentFor(StorePayment.bit), CartPaymentMethod.bit);
      expect(cartPaymentFor(StorePayment.supplierCredit),
          CartPaymentMethod.supplierCredit);
      expect(cartPaymentFor(StorePayment.card), CartPaymentMethod.card);
      expect(cartPaymentFor(StorePayment.applePay), CartPaymentMethod.card);
    });
    test('delivery maps self-pickup flag', () {
      expect(cartDeliveryFor(true), CartDelivery.pickup);
      expect(cartDeliveryFor(false), CartDelivery.standard);
    });
  });

  group('notification date grouping', () {
    test('new header only when the date group changes', () {
      expect(isNewDateGroup(null, 'היום'), isTrue);
      expect(isNewDateGroup('היום', 'היום'), isFalse);
      expect(isNewDateGroup('היום', 'אתמול'), isTrue);
    });
  });
}
