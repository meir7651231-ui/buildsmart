// CROSS-PERSONA WIRING W1 — the KEYSTONE proof that "contractor → manager" is
// LIVE. A contractor placing an order through the real store checkout must flow
// into the SHARED `ordersEngineProvider` — the same engine the manager reads —
// so the manager's open-order count rises and the order shows in the manager's
// 🚚 order list, with NO manual refresh.
//
// This pins the wiring added in `store_screen.dart`'s `_CheckoutSheet` onPressed
// (the "אישור הזמנה" button), where — right beside the existing local
// `storeOrdersProvider` write — a `placeOrder(...)` call pushes the same order
// onto the engine (the app's `syncOrderToSystem`). who = the contractor's
// profile name, site = the cart's project, items = the line count, sum = total.
//
// Two layers of proof:
//   1) WIDGET-DRIVEN: drive the real cart → tap "הזמן עכשיו" → "אישור הזמנה"
//      and assert the engine + managerAnalytics react.
//   2) MANAGER SEES IT: mount the MANAGER dashboard in the SAME container after
//      that checkout and find the contractor's order in the 🚚 list — proving
//      the two roles share one live source.

import 'package:buildsmart/screens/manager_dashboard_screen.dart';
import 'package:buildsmart/screens/store_screen.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/state/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> settle(WidgetTester t, [int frames = 6]) async {
    for (var i = 0; i < frames; i++) {
      await t.pump(const Duration(milliseconds: 120));
    }
  }

  // A single shared container hosts BOTH the contractor's store and the
  // manager's dashboard, so the engine they read is literally the same — that
  // is the whole point of the "live" proof.
  Future<ProviderContainer> pumpStoreCart(WidgetTester t) async {
    SharedPreferences.setMockInitialValues({});
    // A roomy surface so the cart's own horizontal rows (supplier header, summary)
    // never trip a cosmetic RenderFlex overflow — this test is about the wiring,
    // not pixel layout.
    await t.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => t.binding.setSurfaceSize(null));

    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Open the cart section before the first frame.
    container.read(storeSectionProvider.notifier).state = StoreSection.cart;

    await t.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          locale: Locale('he'),
          home: Scaffold(body: StoreScreen()),
        ),
      ),
    );
    await settle(t);
    return container;
  }

  // Seed one real cart line (a contractor "added a product"). brandPrice*qty is
  // the line total; this drives the cart subtotal/total like the catalog does.
  void seedCartLine(
    ProviderContainer c, {
    required int brandPrice,
    required int qty,
  }) {
    c.read(smartCartProvider.notifier).add(
          SmartCartLine(
            productKey: 'test-prod',
            productName: 'מוצר בדיקה',
            productEmoji: '🧱',
            brandName: 'מותג בדיקה',
            brandPrice: brandPrice,
            productQty: qty,
            accessories: const [],
          ),
        );
  }

  // Run the full contractor checkout via the real UI: tap "הזמן עכשיו" (opens the
  // summary sheet), then "אישור הזמנה" (the wired confirm).
  Future<void> tapCheckout(WidgetTester t) async {
    final orderNow = find.textContaining('הזמן עכשיו');
    await t.ensureVisible(orderNow.first);
    await settle(t);
    await t.tap(orderNow.first);
    await settle(t);
    expect(
      find.text('אישור הזמנה'),
      findsOneWidget,
      reason: 'checkout summary sheet should open',
    );
    await t.tap(find.text('אישור הזמנה'));
    await settle(t);
  }

  group('contractor checkout → shared orders engine (LIVE to manager)', () {
    testWidgets(
        'KEYSTONE — confirming "אישור הזמנה" pushes the order onto the engine '
        'AND raises managerAnalytics.openOrders 4 → 5', (t) async {
      final c = await pumpStoreCart(t);

      // The contractor is a registered profile — their name must travel onto the
      // order as `who` (this is what the manager sees).
      c.read(userProfileProvider.notifier).register(
            name: 'אבי הקבלן',
            contact: '050-1111111',
          );
      // A real cart: 4 units × ₪500 = ₪2,000 subtotal (no min/large gates trip
      // at the default store settings).
      seedCartLine(c, brandPrice: 500, qty: 4);
      await settle(t);

      // Baseline: the engine holds the 4 seed orders, all open.
      expect(c.read(ordersEngineProvider).length, 4);
      expect(c.read(managerAnalyticsProvider).openOrders, 4);
      final openBefore = c.read(managerAnalyticsProvider).openOrders;

      await tapCheckout(t);

      // The engine grew by exactly one, and the new (prepended) order carries the
      // contractor's name, the cart's project (now the ACTIVE project — the
      // projects engine is canonical for an order's site), the line count (4),
      // and a positive total — sourced from the SAME cart values the local order used.
      final orders = c.read(ordersEngineProvider);
      expect(orders.length, 5, reason: 'one new live order was placed');
      final placed = orders.first; // placeOrder prepends (newest first)
      expect(placed.who, 'אבי הקבלן');
      expect(placed.site, 'מגדל הרצליה — קומה 4'); // = kProjects.first (active project)
      expect(placed.items, 4);
      expect(placed.sum, greaterThan(0));
      expect(placed.stage, 'new', reason: 'enters the flow at stage `new`');
      expect(placed.isOpen, isTrue);

      // THE LIVE LINK: the manager's open-order count the dashboard reads rose by
      // one (4 → 5), purely because the contractor placed an order.
      expect(c.read(managerAnalyticsProvider).openOrders, openBefore + 1);
      expect(c.read(managerAnalyticsProvider).openOrders, 5);

      // The local store-order write still happened (additive — nothing broke).
      expect(
        c.read(storeOrdersProvider).first.items,
        '4 פריטים',
        reason: 'existing local order behavior is intact',
      );
      // ...and the cart was cleared, as before.
      expect(c.read(smartCartProvider), isEmpty);
    });

    testWidgets(
        'an UNREGISTERED (demo) contractor still places a live order, '
        'attributed to the "קבלן" persona', (t) async {
      final c = await pumpStoreCart(t);
      // No register() — the profile name is empty (a guest/demo contractor).
      expect(c.read(userProfileProvider).name, '');
      seedCartLine(c, brandPrice: 300, qty: 2);
      await settle(t);

      expect(c.read(managerAnalyticsProvider).openOrders, 4);
      await tapCheckout(t);

      final placed = c.read(ordersEngineProvider).first;
      expect(placed.who, 'קבלן', reason: 'empty profile → persona fallback');
      expect(placed.items, 2);
      expect(c.read(managerAnalyticsProvider).openOrders, 5);
    });

    testWidgets(
        'MANAGER SEES IT — after the contractor checkout, the manager 🚚 list '
        'shows the contractor order (same shared engine, one container)',
        (t) async {
      final c = await pumpStoreCart(t);
      c.read(userProfileProvider.notifier).register(
            name: 'דנה בנאי',
            contact: '050-2222222',
          );
      c.read(cartProjectProvider.notifier).state = 'מגדל עזריאלי';
      seedCartLine(c, brandPrice: 700, qty: 3);
      await settle(t);

      await tapCheckout(t);

      // Grab the order the contractor just placed.
      final placed = c.read(ordersEngineProvider).first;
      expect(placed.who, 'דנה בנאי');
      expect(placed.site, 'מגדל עזריאלי');

      // Now mount the MANAGER dashboard in the SAME container — it reads the same
      // ordersEngineProvider, so the contractor's brand-new order is already
      // there with no refresh.
      await t.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: const MaterialApp(
            locale: Locale('he'),
            home: ManagerDashboardScreen(),
          ),
        ),
      );
      await settle(t);

      // Open the 🚚 הזמנות tab (its toggle pill).
      await t.tap(find.text('הזמנות').first);
      await settle(t);

      // The contractor's order id + who·site row are on the manager's screen.
      expect(
        find.text('📦 ${placed.id}'),
        findsOneWidget,
        reason: 'the contractor order row shows for the manager',
      );
      expect(find.text('${placed.who} · ${placed.site}'), findsOneWidget);

      // And the manager's live open-order analytics counts it (5 open now).
      expect(c.read(managerAnalyticsProvider).openOrders, 5);
    });
  });
}
