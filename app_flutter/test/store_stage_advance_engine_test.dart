// CROSS-PERSONA WIRING W2 (STORE) — proof that "store → manager" is LIVE. The
// 🏪 חנות ספק persona owns the FRONT of the order flow (new → preparing →
// ready), then hands off to the courier (ready → pickup). The store advance is
// the SHARED role primitive `sysOrdersProvider.storeAdvance(id)`, which delegates
// to the single `ordersEngineProvider.advance(id)` — the very engine the MANAGER
// reads. So a store approve/pick/ready/hand-off must immediately move the order's
// stage AND reflow the manager's live analytics + order list, with no refresh.
//
// These tests drive that role primitive DIRECTLY in one ProviderContainer (the
// store role-app and the manager derivations share literally the same engine),
// asserting the same stage transitions, ownership gates and manager numbers the
// dial-driven tests used to assert — just through the engine, not a widget.

import 'package:buildsmart/data/supplier_data.dart';
import 'package:buildsmart/logic/manager_dashboard.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:buildsmart/state/sys_orders.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('store stage-advance → shared engine (LIVE to manager)', () {
    test(
        'KEYSTONE — storeAdvance on the seed `new` order advances it '
        'new → preparing on the SHARED engine; the manager sees it live', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);

      // The seed has exactly one `new` order (BS-1042) — that is what the store
      // owns under לאישור.
      final newOrder =
          c.read(ordersEngineProvider).firstWhere((o) => o.stage == 'new');
      expect(newOrder.id, 'BS-1042');
      // Manager baseline: 4 open, 1 in `new`, 1 in `preparing`.
      expect(c.read(managerAnalyticsProvider).openOrders, 4);
      int countAt(String stage) =>
          c.read(ordersEngineProvider).where((o) => o.stage == stage).length;
      expect(countAt('new'), 1);
      expect(countAt('preparing'), 1);

      // The store approves the order via the shared role primitive.
      c.read(sysOrdersProvider.notifier).storeAdvance(newOrder.id);

      // THE LIVE LINK: the order moved new → preparing on the shared engine, and
      // the store projection (sysOrdersProvider) re-derived to match.
      final moved =
          c.read(ordersEngineProvider).firstWhere((o) => o.id == newOrder.id);
      expect(moved.stage, 'preparing', reason: 'store advanced it one stage');
      expect(
        c
            .read(sysOrdersProvider)
            .firstWhere((o) => o.id == newOrder.id)
            .stage,
        OrderStage.preparing,
        reason: 'the store role view reflects the advance live',
      );
      // The manager's live stage counts reflect it immediately: `new` emptied,
      // `preparing` grew by one. (Open-orders is unchanged — still not delivered.)
      expect(countAt('new'), 0, reason: 'manager sees the new stage empty');
      expect(countAt('preparing'), 2, reason: 'manager sees preparing rise');
      expect(c.read(managerAnalyticsProvider).openOrders, 4);
    });

    test(
        'FULL STORE CHAIN — new → preparing → ready → pickup, one storeAdvance '
        'per stage, each move visible to the manager live', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);

      final store = c.read(sysOrdersProvider.notifier);
      final id =
          c.read(ordersEngineProvider).firstWhere((o) => o.stage == 'new').id;
      String stageOf() =>
          c.read(ordersEngineProvider).firstWhere((o) => o.id == id).stage;

      // לאישור (new) → אשר הזמנה ⇒ preparing.
      store.storeAdvance(id);
      expect(stageOf(), 'preparing');

      // בהכנה (preparing) → סמן מוכן ⇒ ready.
      store.storeAdvance(id);
      expect(stageOf(), 'ready', reason: 'store handed it to ready');

      // מוכנות (ready) → מסור לשליח ⇒ pickup (the handoff to the courier).
      store.storeAdvance(id);
      expect(stageOf(), 'pickup', reason: 'store advanced ready → pickup');

      // GATE: once it is `pickup` the courier owns it — a further storeAdvance is
      // a no-op (the store cannot push past its hand-off).
      store.storeAdvance(id);
      expect(stageOf(), 'pickup', reason: 'storeAdvance no-ops at the courier stage');

      // The manager, reading the SAME engine, now counts this order under
      // `pickup` (it left `new`/`preparing`/`ready`) — purely from store calls.
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

      final newId =
          c.read(ordersEngineProvider).firstWhere((o) => o.stage == 'new').id;

      expect(c.read(managerAnalyticsProvider).openOrders, 4);
      // STORE approves: advance new → preparing through the role primitive.
      c.read(sysOrdersProvider.notifier).storeAdvance(newId);

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

    test('storeAdvance walks exactly the three front-of-flow stages', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final store = c.read(sysOrdersProvider.notifier);
      final id =
          c.read(ordersEngineProvider).firstWhere((o) => o.stage == 'new').id;
      String stageOf() =>
          c.read(ordersEngineProvider).firstWhere((o) => o.id == id).stage;

      // The three stages the store advances OUT of are exactly the front of the
      // flow (no invented stage); each is part of the manager's order flow.
      for (final stage in const ['new', 'preparing', 'ready']) {
        expect(kManagerOrderFlow, contains(stage));
        expect(stageOf(), stage);
        store.storeAdvance(id);
      }
      // After the three advances it has reached the courier's hand-off stage.
      expect(stageOf(), 'pickup');
    });
  });
}
