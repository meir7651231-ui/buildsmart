// CROSS-PERSONA WIRING W2 (COURIER) — proof that "courier → manager" is LIVE.
// The 🛵 שליח persona owns the BACK of the order flow (ready → pickup → transit
// → delivered). Its delivery leaves open an INLINE panel over the SHARED
// `ordersEngineProvider`, and each open row's advance button calls `.advance(id)`
// on that same engine — the very engine the MANAGER reads. So a courier
// pick-up / depart / deliver must immediately move the order's stage AND reflow
// the manager's live analytics + order list, with no refresh.
//
//   • pickup       (משלוחים ממתינים לאיסוף) → stage `ready`     → מסור לשליח — ready→pickup.
//   • ca-pickup    (אספתי מהחנות)            → stage `pickup`    → יצאתי לדרך — pickup→transit.
//   • ca-transit   (יצאתי לדרך)              → stage `transit`   → סמן נמסר — transit→delivered.
//   • ca-delivered (נמסר ללקוח)             → stage `delivered` — terminal (✓ נמסר, no button).
//
// Two layers of proof, BOTH hosting the courier dial + the manager derivations
// in ONE ProviderContainer (so the engine they touch is literally the same):
//   1) WIDGET-DRIVEN full BACK chain ready → … → delivered, one leaf per stage,
//      keyed advance taps; the manager's open-orders drops 4 → 3 exactly when the
//      order is delivered — purely from courier taps.
//   2) PURE one-container: a courier advance chain to `delivered` writes the
//      engine and managerAnalyticsProvider reflects it live.

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

  // Tap a dial ROW by its title (scoped to a DialRow so a panel header repeating
  // the same label never makes the finder ambiguous).
  Future<void> tapRow(WidgetTester t, String title) async {
    await t.tap(
      find.descendant(of: find.byType(DialRow), matching: find.text(title)),
    );
    await settle(t);
  }

  group('courier stage-advance → shared engine (LIVE to manager)', () {
    testWidgets(
        'FULL BACK CHAIN — ready → pickup → transit → delivered via the courier '
        'leaves; the manager open-orders drops 4 → 3 on delivery, live',
        (t) async {
      final c = await pump(t);

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
      final advanceBtn = find.byKey(ValueKey('advance-$id'));

      // Enter the courier persona.
      c.read(activePersonaProvider.notifier).state = 'courier';
      await settle(t);

      // pickup leaf (stage `ready`) sits at L2 directly under the persona.
      await tapRow(t, 'משלוחים ממתינים לאיסוף');
      expect(c.read(bsCourierLeafProvider), 'pickup');
      expect(find.text('📦 $id'), findsOneWidget);
      // אספתי מהחנות (ready → pickup).
      await t.tap(advanceBtn);
      await settle(t);
      expect(stageOf(), 'pickup', reason: 'courier picked it up');

      // The three ca-* leaves live under the משלוחים פעילים sub-tree — drill in.
      // (Re-tapping the pickup leaf closed its panel; open the active group.)
      await tapRow(t, 'משלוחים פעילים');
      await tapRow(t, 'אספתי מהחנות'); // ca-pickup, stage `pickup`
      expect(c.read(bsCourierLeafProvider), 'ca-pickup');
      expect(find.text('📦 $id'), findsOneWidget);
      // יצאתי לדרך (pickup → transit).
      await t.tap(advanceBtn);
      await settle(t);
      expect(stageOf(), 'transit', reason: 'courier departed');

      await tapRow(t, 'יצאתי לדרך'); // ca-transit, stage `transit`
      expect(c.read(bsCourierLeafProvider), 'ca-transit');
      expect(find.text('📦 $id'), findsOneWidget);
      // Still 4 open right up to the moment before delivery.
      expect(c.read(managerAnalyticsProvider).openOrders, 4);
      // סמן נמסר (transit → delivered).
      await t.tap(advanceBtn);
      await settle(t);
      expect(stageOf(), 'delivered', reason: 'courier delivered it');

      // THE LIVE LINK: the manager's open-order count the dashboard reads fell by
      // exactly one (4 → 3), purely because the courier delivered — same engine.
      expect(c.read(managerAnalyticsProvider).openOrders, 3);

      // The delivered leaf shows the order as completed (terminal): a "✓ נמסר"
      // note and NO advance button for it.
      await tapRow(t, 'נמסר ללקוח'); // ca-delivered, stage `delivered`
      expect(c.read(bsCourierLeafProvider), 'ca-delivered');
      expect(find.text('📦 $id'), findsOneWidget);
      expect(find.text('✓ נמסר'), findsWidgets);
      expect(
        find.byKey(ValueKey('advance-$id')),
        findsNothing,
        reason: 'a delivered order has no advance affordance',
      );
    });

    testWidgets(
        'the courier pickup leaf shows the store-ready order — the live HANDOFF '
        '(store so-ready and courier pickup both read stage `ready`)', (t) async {
      final c = await pump(t);
      final readyId = c
          .read(ordersEngineProvider)
          .firstWhere((o) => o.stage == 'ready')
          .id;

      c.read(activePersonaProvider.notifier).state = 'courier';
      await settle(t);
      await tapRow(t, 'משלוחים ממתינים לאיסוף');
      // The same order the store had under מוכנות is here for the courier, with
      // an advance affordance (so the courier can pick it up).
      expect(find.text('📦 $readyId'), findsOneWidget);
      expect(find.byKey(ValueKey('advance-$readyId')), findsOneWidget);
    });

    test(
        'PURE — a courier advance chain to delivered writes the engine and '
        'managerAnalytics reflects it live in ONE container (no widgets)', () {
      final c = ProviderContainer();
      addTearDown(c.dispose);

      final engine = c.read(ordersEngineProvider.notifier);
      final id =
          c.read(ordersEngineProvider).firstWhere((o) => o.stage == 'ready').id;

      expect(c.read(managerAnalyticsProvider).openOrders, 4);

      // COURIER drives ready → pickup → transit → delivered.
      engine
        ..advance(id) // ready → pickup
        ..advance(id) // pickup → transit
        ..advance(id); // transit → delivered

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

    test('kCourierOrderLeafStage maps exactly the four back-of-flow stages', () {
      expect(kCourierOrderLeafIds, {
        'pickup',
        'ca-pickup',
        'ca-transit',
        'ca-delivered',
      });
      expect(
        kCourierOrderLeafStage.values.toList(),
        ['ready', 'pickup', 'transit', 'delivered'],
      );
      for (final stage in kCourierOrderLeafStage.values) {
        expect(kManagerOrderFlow, contains(stage));
      }
    });
  });
}
