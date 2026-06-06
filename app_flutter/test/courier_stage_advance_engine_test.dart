// CROSS-PERSONA WIRING W2 (COURIER) — proof that "courier → manager" is LIVE.
// Two-step hand-off: the STORE owns ready→pickup ("מסור לשליח"); the 🛵 שליח
// then owns pickup→transit→delivered. The courier's leaves open an INLINE panel
// over the SHARED `ordersEngineProvider` and advance via the role primitive — the
// very engine the MANAGER reads — so a courier receive / deliver immediately
// moves the stage AND reflows the manager's live analytics, with no refresh.
//
//   • pickup       (משלוחים ממתינים לאיסוף) → stage `ready`     → VIEW-ONLY (store hands off).
//   • ca-pickup    (אספתי מהחנות)            → stage `pickup`    → receive → transit.
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
        'TWO-STEP — store hands off (ready→pickup), then the courier receives '
        '(pickup→transit) and delivers; manager open-orders drops 4 → 3, live',
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
      // The pickup leaf (stage `ready`) is VIEW-ONLY: the STORE owns the hand-off
      // (ready→pickup), so the courier has no advance affordance for a ready order.
      expect(advanceBtn, findsNothing,
          reason: 'the store hands off; the courier cannot advance a ready order');
      // The store hands it off (ready→pickup) on the shared engine.
      c.read(ordersEngineProvider.notifier).advance(id);
      await settle(t);
      expect(stageOf(), 'pickup', reason: 'store handed it to the courier');

      // The ca-* leaves live under the משלוחים פעילים sub-tree — drill in.
      await tapRow(t, 'משלוחים פעילים');
      await tapRow(t, 'אספתי מהחנות'); // ca-pickup, stage `pickup`
      expect(c.read(bsCourierLeafProvider), 'ca-pickup');
      expect(find.text('📦 $id'), findsOneWidget);
      // courier RECEIVES the handed-off order (pickup → transit).
      await t.tap(advanceBtn);
      await settle(t);
      expect(stageOf(), 'transit', reason: 'courier received it');

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
      // The same ready order the store sees under מוכנות appears here for the
      // courier — but VIEW-ONLY: the store owns the hand-off (ready→pickup), so
      // there is NO advance affordance on the courier's side for a ready order.
      expect(find.text('📦 $readyId'), findsOneWidget);
      expect(find.byKey(ValueKey('advance-$readyId')), findsNothing,
          reason: 'the store hands off; the courier cannot advance a ready order');
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
