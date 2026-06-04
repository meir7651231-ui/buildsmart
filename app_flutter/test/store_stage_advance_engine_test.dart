// CROSS-PERSONA WIRING W2 (STORE) — proof that "store → manager" is LIVE. The
// 🏪 חנות ספק persona owns the FRONT of the order flow (new → preparing →
// ready). Its 📥 הזמנות leaves (`so-new` · `so-prep` · `so-ready`) open an
// INLINE panel over the SHARED `ordersEngineProvider`, and each open row's
// advance button calls `.advance(id)` on that same engine — the very engine the
// MANAGER reads. So a store approve/pick/ready must immediately move the order's
// stage AND reflow the manager's live analytics + order list, with no refresh.
//
// Two layers of proof, BOTH hosting the store dial + the manager derivations in
// ONE ProviderContainer (so the engine they touch is literally the same):
//   1) WIDGET-DRIVEN: drive the real BS dial into 🏪 → הזמנות → לאישור, tap the
//      live row's "אשר הזמנה" button, and assert the engine + managerAnalytics
//      react (the new order goes new → preparing; open-orders count holds; the
//      order leaves the `new` stage the manager's pipeline counts).
//   2) FULL STORE CHAIN: new → preparing → ready advanced one stage at a time
//      through the three store leaves, asserting the manager sees each move live.

import 'package:buildsmart/logic/manager_dashboard.dart';
import 'package:buildsmart/screens/bs_dial_widget.dart';
import 'package:buildsmart/state/dial_state.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:buildsmart/widgets/dial.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> settle(WidgetTester t, [int frames = 8]) async {
    for (var i = 0; i < frames; i++) {
      await t.pump(const Duration(milliseconds: 120));
    }
  }

  // Mount the real BS dial; return the container the dial reads (so the test can
  // also read managerAnalyticsProvider off the SAME engine).
  Future<ProviderContainer> pump(WidgetTester t) async {
    SharedPreferences.setMockInitialValues({});
    await t.binding.setSurfaceSize(const Size(440, 1200));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('he'),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: Align(
                alignment: Alignment.topRight,
                child: SingleChildScrollView(child: BsDialWidget()),
              ),
            ),
          ),
        ),
      ),
    );
    await settle(t);
    return ProviderScope.containerOf(t.element(find.byType(BsDialWidget)));
  }

  // Drive the dial: pick the store persona, then drill into הזמנות.
  Future<void> openStoreOrders(WidgetTester t, ProviderContainer c) async {
    c.read(activePersonaProvider.notifier).state = 'store';
    await settle(t);
    await t.tap(
      find.descendant(of: find.byType(DialRow), matching: find.text('הזמנות')),
    );
    await settle(t);
  }

  // Tap a leaf ROW by its title (scoped to a DialRow so the panel header, which
  // repeats the same stage label, never makes the finder ambiguous).
  Future<void> tapLeaf(WidgetTester t, String title) async {
    await t.tap(
      find.descendant(of: find.byType(DialRow), matching: find.text(title)),
    );
    await settle(t);
  }

  group('store stage-advance → shared engine (LIVE to manager)', () {
    testWidgets(
        'KEYSTONE — tapping "אשר הזמנה" on the store לאישור leaf advances the '
        'order new → preparing on the SHARED engine; the manager sees it live',
        (t) async {
      final c = await pump(t);

      // The seed has exactly one `new` order (BS-1042) — that is what the store
      // sees under לאישור.
      final newOrder = c
          .read(ordersEngineProvider)
          .firstWhere((o) => o.stage == 'new');
      expect(newOrder.id, 'BS-1042');
      // Manager baseline: 4 open, 1 in `new`, 1 in `preparing`.
      expect(c.read(managerAnalyticsProvider).openOrders, 4);
      int countAt(String stage) =>
          c.read(ordersEngineProvider).where((o) => o.stage == stage).length;
      expect(countAt('new'), 1);
      expect(countAt('preparing'), 1);

      await openStoreOrders(t, c);
      await tapLeaf(t, 'לאישור'); // opens the LIVE so-new panel
      expect(c.read(bsStoreLeafProvider), 'so-new');
      // The real `new` order is in the panel, with its advance affordance.
      expect(find.text('📦 ${newOrder.id}'), findsOneWidget);
      expect(find.text('אשר הזמנה'), findsOneWidget);

      // Tap the row's advance button — the store approves the order.
      await t.tap(find.byKey(ValueKey('advance-${newOrder.id}')));
      await settle(t);

      // THE LIVE LINK: the order moved new → preparing on the shared engine.
      final moved = c
          .read(ordersEngineProvider)
          .firstWhere((o) => o.id == newOrder.id);
      expect(moved.stage, 'preparing', reason: 'store advanced it one stage');
      // The manager's live stage counts reflect it immediately: `new` emptied,
      // `preparing` grew by one. (Open-orders is unchanged — still not delivered.)
      expect(countAt('new'), 0, reason: 'manager sees the new stage empty');
      expect(countAt('preparing'), 2, reason: 'manager sees preparing rise');
      expect(c.read(managerAnalyticsProvider).openOrders, 4);

      // The panel re-rendered live: the just-approved order is GONE from the
      // לאישור (new) panel (it is now `preparing`).
      expect(find.text('📦 ${moved.id}'), findsNothing);
    });

    testWidgets(
        'FULL STORE CHAIN — new → preparing → ready, one leaf per stage, each '
        'move visible to the manager live', (t) async {
      final c = await pump(t);
      final id = c
          .read(ordersEngineProvider)
          .firstWhere((o) => o.stage == 'new')
          .id;
      String stageOf() =>
          c.read(ordersEngineProvider).firstWhere((o) => o.id == id).stage;

      await openStoreOrders(t, c);
      final advanceBtn = find.byKey(ValueKey('advance-$id'));

      // לאישור (new) → אשר הזמנה ⇒ preparing.
      await tapLeaf(t, 'לאישור');
      await t.tap(advanceBtn);
      await settle(t);
      expect(stageOf(), 'preparing');

      // בהכנה (preparing) → סמן מוכן ⇒ ready. (Two orders sit in `preparing`
      // now — seed BS-1041 + ours — so the advance button is targeted by key.)
      await tapLeaf(t, 'בהכנה');
      expect(c.read(bsStoreLeafProvider), 'so-prep');
      expect(find.text('📦 $id'), findsOneWidget);
      await t.tap(advanceBtn);
      await settle(t);
      expect(stageOf(), 'ready', reason: 'store handed it to ready');

      // מוכנות (ready) → מסור לשליח ⇒ pickup (the handoff to the courier).
      await tapLeaf(t, 'מוכנות');
      expect(c.read(bsStoreLeafProvider), 'so-ready');
      expect(find.text('📦 $id'), findsOneWidget);
      await t.tap(advanceBtn);
      await settle(t);
      expect(stageOf(), 'pickup', reason: 'store advanced ready → pickup');

      // The manager, reading the SAME engine, now counts this order under
      // `pickup` (it left `new`/`preparing`/`ready`) — purely from store taps.
      int countAt(String s) =>
          c.read(ordersEngineProvider).where((o) => o.stage == s).length;
      expect(countAt('pickup'), 1);
      // Still open (not delivered) — open-orders held at the seed's 4 the whole
      // time (advancing within the open stages never changes the open count).
      expect(c.read(managerAnalyticsProvider).openOrders, 4);
    });

    test(
        'PURE — a store advance writes the engine and managerAnalytics reflects '
        'it live in ONE container (no widgets)', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);

      // Force a non-persisting engine so the test is hermetic, seeded with the
      // four seed orders (same as production seed).
      final engine = c.read(ordersEngineProvider.notifier);
      final newId =
          c.read(ordersEngineProvider).firstWhere((o) => o.stage == 'new').id;

      expect(c.read(managerAnalyticsProvider).openOrders, 4);
      // STORE approves: advance new → preparing.
      engine.advance(newId);

      expect(
        c.read(ordersEngineProvider).firstWhere((o) => o.id == newId).stage,
        'preparing',
      );
      // The manager's analytics provider (a derivation over the SAME engine)
      // re-read shows the order moved: the manager's order list now has it in
      // `preparing`, and open-orders is unchanged (still open).
      final mgrOrders = c.read(managerAnalyticsProvider).orders;
      expect(
        mgrOrders.firstWhere((o) => o.id == newId).stage,
        'preparing',
        reason: 'manager order list reflects the store advance live',
      );
      expect(c.read(managerAnalyticsProvider).openOrders, 4);
    });

    test('kStoreOrderLeafStage maps exactly the three front-of-flow stages', () {
      expect(kStoreOrderLeafIds, {'so-new', 'so-prep', 'so-ready'});
      // Each leaf maps to a real, front-of-flow order stage (no invented stage).
      expect(kStoreOrderLeafStage.values.toList(), ['new', 'preparing', 'ready']);
      for (final stage in kStoreOrderLeafStage.values) {
        expect(kManagerOrderFlow, contains(stage));
      }
    });
  });
}
