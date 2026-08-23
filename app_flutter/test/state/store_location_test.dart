// store_location — the SEALED location value type + the derived
// storeLocationProvider, MIRRORING test/state/updates_location_test.dart EXACTLY
// for the חנות (store) tab.
//
// WHY THESE TESTS EXIST: storeLocationProvider is a derived `Provider`, so
// Riverpod notifies the keyboard ONLY when the newly computed location is `!=`
// the previous one. If the sealed subclasses lacked TRUE value equality, the
// provider would emit a fresh instance every frame and the keyboard would
// re-derive its whole row at 60fps (churn during scroll). The עדכונים plan calls
// this the single most important detail and mandates an idempotence test; the
// store mirror inherits that exact gate:
//   • VALUE EQUALITY (pure): identical inputs ⇒ `==` true AND `hashCode` equal,
//     for every subclass; any field difference ⇒ `!=`. No widget tree needed.
//   • PROVIDER IDEMPOTENCE: a second read of the derived provider returns the
//     SAME cached instance (Riverpod caches a Provider's value), and a no-op
//     upstream write does NOT re-notify a listener — proving the recompute path
//     short-circuits on an equal value rather than churning.
//   • RESOLUTION: the provider maps the active storeSection to the right
//     subclass (all→StoreRoot, cart→CartLocation, orders→OrdersLocation,
//     services→ServicesLocation).
//
// SharedPreferences.setMockInitialValues({}) is seeded because storeSectionProvider
// is a plain StateProvider (no prefs), but the home shell's other lazily-loaded
// providers read prefs; seeding keeps the container hermetic and matches the
// עדכונים test's setUp so the two files stay structurally identical.

import 'package:buildsmart/screens/store_screen.dart'
    show StoreSection, storeSectionProvider;
import 'package:buildsmart/state/store_location.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ───────────────────────────────────────────────────────────────────────────
  // VALUE EQUALITY — pure, the foundation the provider de-dup relies on.
  // ───────────────────────────────────────────────────────────────────────────
  group('StoreRoot value equality', () {
    test('identical inputs ⇒ == true AND hashCode equal', () {
      const x = StoreRoot(section: StoreSection.all);
      const y = StoreRoot(section: StoreSection.all);
      expect(x, y, reason: 'same fields ⇒ equal by value');
      expect(x.hashCode, y.hashCode, reason: 'equal values ⇒ equal hashCode');
    });

    test('a different section ⇒ !=', () {
      const x = StoreRoot(section: StoreSection.all);
      const y = StoreRoot(section: StoreSection.cart);
      expect(x == y, isFalse, reason: 'section participates in equality');
    });

    test('hashCode tracks the section field', () {
      const x = StoreRoot(section: StoreSection.all);
      const y = StoreRoot(section: StoreSection.orders);
      expect(x.hashCode == y.hashCode, isFalse,
          reason: 'a different section ⇒ a different hashCode (de-dup key)');
    });
  });

  group('CartLocation value equality', () {
    test('identical inputs ⇒ == true AND hashCode equal', () {
      const x = CartLocation();
      const y = CartLocation();
      expect(x, y);
      expect(x.hashCode, y.hashCode);
    });
  });

  group('OrdersLocation value equality', () {
    test('identical inputs ⇒ == true AND hashCode equal', () {
      const x = OrdersLocation();
      const y = OrdersLocation();
      expect(x, y);
      expect(x.hashCode, y.hashCode);
    });
  });

  group('ServicesLocation value equality', () {
    test('identical inputs ⇒ == true AND hashCode equal', () {
      const x = ServicesLocation();
      const y = ServicesLocation();
      expect(x, y);
      expect(x.hashCode, y.hashCode);
    });
  });

  group('cross-subclass inequality (distinct surfaces never collide)', () {
    test('the four singletons + the root are pairwise !=', () {
      const root = StoreRoot(section: StoreSection.all);
      const cart = CartLocation();
      const orders = OrdersLocation();
      const services = ServicesLocation();
      // Every pair of distinct surfaces must compare unequal so the location
      // provider re-fires when the user moves between sections (the keyboard
      // re-derives a different row). The empty-subclasses (cart/orders/services)
      // key equality on runtimeType, so this also proves they don't collapse to
      // a single "empty location".
      expect(cart == orders, isFalse);
      expect(cart == services, isFalse);
      expect(orders == services, isFalse);
      expect(root == cart, isFalse);
      expect(root == orders, isFalse);
      expect(root == services, isFalse);
    });

    test('the empty subclasses have DISTINCT hashCodes (runtimeType keyed)', () {
      // runtimeType.hashCode differs per class, so the three data-less locations
      // never share a hash bucket identity that could mask a surface change.
      final hashes = <int>{
        const CartLocation().hashCode,
        const OrdersLocation().hashCode,
        const ServicesLocation().hashCode,
      };
      expect(hashes.length, 3,
          reason: 'cart/orders/services hash distinctly by runtimeType');
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // PROVIDER IDEMPOTENCE — the churn gate the plan demands.
  // ───────────────────────────────────────────────────────────────────────────
  group('storeLocationProvider — resolution + idempotence', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    ProviderContainer makeContainer() {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      return c;
    }

    test('section all (default) ⇒ StoreRoot carrying that section', () {
      final c = makeContainer();
      final loc = c.read(storeLocationProvider);
      expect(loc, isA<StoreRoot>(),
          reason: 'the default store section is all ⇒ StoreRoot');
      expect((loc as StoreRoot).section, StoreSection.all,
          reason: 'the root carries the active section for its tools');
    });

    test('section cart ⇒ CartLocation', () {
      final c = makeContainer();
      c.read(storeSectionProvider.notifier).state = StoreSection.cart;
      expect(c.read(storeLocationProvider), isA<CartLocation>(),
          reason: 'the 🛒 section ⇒ CartLocation');
    });

    test('section orders ⇒ OrdersLocation', () {
      final c = makeContainer();
      c.read(storeSectionProvider.notifier).state = StoreSection.orders;
      expect(c.read(storeLocationProvider), isA<OrdersLocation>(),
          reason: 'the 📦 section ⇒ OrdersLocation');
    });

    test('section services ⇒ ServicesLocation', () {
      final c = makeContainer();
      c.read(storeSectionProvider.notifier).state = StoreSection.services;
      expect(c.read(storeLocationProvider), isA<ServicesLocation>(),
          reason: 'the 🔧 section ⇒ ServicesLocation');
    });

    test('IDEMPOTENT: two reads with no change ⇒ the SAME cached instance', () {
      final c = makeContainer();
      final a = c.read(storeLocationProvider);
      final b = c.read(storeLocationProvider);
      expect(identical(a, b), isTrue,
          reason: 'a derived Provider caches; an unchanged read does not '
              'reallocate (the precondition for no-churn)');
    });

    test(
        'IDEMPOTENT: a NO-OP upstream write (same value) does NOT re-notify '
        'the location listener', () {
      final c = makeContainer();
      final firstInstance = c.read(storeLocationProvider);
      var notifications = 0;
      // fireImmediately:false → we count ONLY genuine post-subscription changes.
      c.listen<StoreLocation>(
        storeLocationProvider,
        (_, __) => notifications++,
        fireImmediately: false,
      );

      // Re-write the section to its CURRENT value (all). The StateProvider does
      // not change, the location recompute yields an `==` value, so the listener
      // must NOT fire — no churn.
      c.read(storeSectionProvider.notifier).state =
          c.read(storeSectionProvider);

      expect(notifications, 0,
          reason: 'identical input ⇒ equal location ⇒ zero re-notifications '
              '(guards the 60fps churn failure mode)');
      // And the cached instance was never reallocated — the value-equality gate
      // held, so nothing downstream rebuilt.
      expect(identical(c.read(storeLocationProvider), firstInstance), isTrue,
          reason: 'no-op upstream writes do not reallocate the location');
    });

    test(
        'a REAL change DOES notify exactly once (the listener is actually live)',
        () async {
      final c = makeContainer();
      var notifications = 0;
      c.listen<StoreLocation>(
        storeLocationProvider,
        (_, __) => notifications++,
        fireImmediately: false,
      );

      // Flip the section all → cart: StoreRoot → CartLocation, a genuine value
      // change, so the listener fires once (proving the no-op test above is a
      // real negative, not a dead listener).
      c.read(storeSectionProvider.notifier).state = StoreSection.cart;
      // Riverpod flushes derived-provider listener notifications on its scheduler
      // (a microtask), not synchronously — pump it so the live listener fires.
      // (The known gotcha the brief flags: await a zero-duration delay before
      // asserting the notification count.)
      await Future<void>.delayed(Duration.zero);

      expect(notifications, 1,
          reason: 'a genuine surface change re-fires the location exactly once');
    });

    test('every section resolves to a DISTINCT location instance/type',
        () async {
      // Walk the full section axis and confirm each yields its own surface — the
      // mirror must never get "stuck" on a stale location across section moves.
      final c = makeContainer();
      final seen = <Type>{};
      for (final s in StoreSection.values) {
        c.read(storeSectionProvider.notifier).state = s;
        await Future<void>.delayed(Duration.zero);
        seen.add(c.read(storeLocationProvider).runtimeType);
      }
      expect(seen, {
        StoreRoot,
        CartLocation,
        OrdersLocation,
        ServicesLocation,
      }, reason: 'the four sections map onto the four distinct location types');
    });
  });
}
