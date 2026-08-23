// CROSS-PERSONA WIRING W2 (COURIER) — proof that "courier → manager" is LIVE. The
// 🛵 שליח persona owns the BACK of the order flow. It is a TWO-STEP hand-off: the
// STORE owns ready → pickup ("מסור לשליח"), and only then does the courier own
// pickup → transit → delivered. The courier advance is the SHARED role primitive
// `sysOrdersProvider.courierAdvance(id)`, which delegates to the single
// `ordersEngineProvider.advance(id)` — the very engine the MANAGER reads. So a
// courier receive / deliver must immediately move the order's stage AND reflow the
// manager's live analytics + order list, with no refresh.
//
// These tests drive that role primitive DIRECTLY in one ProviderContainer (the
// courier role-app and the manager derivations share literally the same engine),
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

  group('courier stage-advance → shared engine (LIVE to manager)', () {
    test(
        'TWO-STEP — store hands off (ready→pickup), then the courier receives '
        '(pickup→transit) and delivers; manager open-orders drops 4 → 3, live',
        () {
      final c = ProviderContainer();
      addTearDown(c.dispose);

      final store = c.read(sysOrdersProvider.notifier);
      final courier = c.read(sysOrdersProvider.notifier);

      // Seed: BS-1040 is `ready` (what the courier sees waiting for pickup);
      // BS-1039 is `transit`. None delivered yet → 4 open.
      final id = c
          .read(ordersEngineProvider)
          .firstWhere((o) => o.stage == 'ready')
          .id;
      expect(id, 'BS-1040');
      expect(c.read(managerAnalyticsProvider).openOrders, 4);
      String stageOf() =>
          c.read(ordersEngineProvider).firstWhere((o) => o.id == id).stage;

      // GATE: while it is `ready` the STORE owns the hand-off — a courierAdvance
      // is a no-op (the courier cannot advance a ready order).
      courier.courierAdvance(id);
      expect(stageOf(), 'ready',
          reason: 'the store hands off; courierAdvance no-ops on a ready order');

      // The store hands it off (ready → pickup) via its role primitive.
      store.storeAdvance(id);
      expect(stageOf(), 'pickup', reason: 'store handed it to the courier');

      // The courier RECEIVES the handed-off order (pickup → transit).
      courier.courierAdvance(id);
      expect(stageOf(), 'transit', reason: 'courier received it');

      // Still 4 open right up to the moment before delivery.
      expect(c.read(managerAnalyticsProvider).openOrders, 4);

      // סמן נמסר (transit → delivered).
      courier.courierAdvance(id);
      expect(stageOf(), 'delivered', reason: 'courier delivered it');

      // THE LIVE LINK: the manager's open-order count the dashboard reads fell by
      // exactly one (4 → 3), purely because the courier delivered — same engine.
      expect(c.read(managerAnalyticsProvider).openOrders, 3);

      // GATE: a delivered order is terminal — a further courierAdvance is a no-op.
      courier.courierAdvance(id);
      expect(stageOf(), 'delivered',
          reason: 'courierAdvance no-ops on a delivered order');
    });

    test(
        'the courier reads the store-ready order live — the HANDOFF (store '
        'so-ready and courier pickup both read stage `ready`)', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);

      final readyId = c
          .read(ordersEngineProvider)
          .firstWhere((o) => o.stage == 'ready')
          .id;

      // The same ready order the store sees under מוכנות is the one the courier's
      // pickup leaf reads from the SHARED engine — but VIEW-ONLY for the courier:
      // the store owns the hand-off (ready→pickup), so courierAdvance no-ops here.
      expect(
        c
            .read(sysOrdersProvider)
            .firstWhere((o) => o.id == readyId)
            .stage,
        OrderStage.ready,
        reason: 'the courier role view reads the store-ready order live',
      );
      c.read(sysOrdersProvider.notifier).courierAdvance(readyId);
      expect(
        c.read(ordersEngineProvider).firstWhere((o) => o.id == readyId).stage,
        'ready',
        reason: 'the store hands off; the courier cannot advance a ready order',
      );
    });

    test(
        'PURE — a courier advance chain to delivered writes the engine and '
        'managerAnalytics reflects it live in ONE container (no widgets)', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);

      final id =
          c.read(ordersEngineProvider).firstWhere((o) => o.stage == 'ready').id;

      expect(c.read(managerAnalyticsProvider).openOrders, 4);

      // STORE hands off (ready → pickup), then the COURIER drives the rest of the
      // back-of-flow (pickup → transit → delivered) through the role primitives.
      final sys = c.read(sysOrdersProvider.notifier);
      sys
        ..storeAdvance(id) // ready → pickup (the store's hand-off)
        ..courierAdvance(id) // pickup → transit
        ..courierAdvance(id); // transit → delivered

      expect(
        c.read(ordersEngineProvider).firstWhere((o) => o.id == id).stage,
        'delivered',
      );
      // Manager's order list (a derivation over the SAME engine) shows it
      // delivered, and open-orders fell 4 → 3 live.
      expect(
        c
            .read(managerAnalyticsProvider)
            .orders
            .firstWhere((o) => o.id == id)
            .stage,
        'delivered',
        reason: 'manager order list reflects the courier delivery live',
      );
      expect(c.read(managerAnalyticsProvider).openOrders, 3);
    });

    test('courierAdvance walks exactly the two back-of-flow stages it owns', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);
      final sys = c.read(sysOrdersProvider.notifier);
      final id =
          c.read(ordersEngineProvider).firstWhere((o) => o.stage == 'ready').id;
      String stageOf() =>
          c.read(ordersEngineProvider).firstWhere((o) => o.id == id).stage;

      // The store hands off first (ready → pickup) — the courier owns from here.
      sys.storeAdvance(id);

      // The two stages the courier advances OUT of are exactly the back of the
      // flow (no invented stage); each is part of the manager's order flow.
      for (final stage in const ['pickup', 'transit']) {
        expect(kManagerOrderFlow, contains(stage));
        expect(stageOf(), stage);
        sys.courierAdvance(id);
      }
      // After the two advances it has reached the terminal delivered stage.
      expect(stageOf(), 'delivered');
    });
  });
}
