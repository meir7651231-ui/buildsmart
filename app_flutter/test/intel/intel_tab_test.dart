// Studio Pillar-3 · step 98 — the manager INTEL READ providers + the 5th tab
// `IntelTab` (📡 מודיעין לקוחות). Covers §5:
//   1. flag-OFF invariant — with `kIntelLive` const-false (the compile default in
//      tests) the manager dashboard shows the verbatim 4 tabs, no 📡 tab, and
//      `tabCount == 4` (the byte-identical lockstep hold);
//   2. the `IntelTab` widget renders under `Directionality(rtl)` with a `Semantics`
//      label and shows DEMO data folded from a seeded `intelLogProvider`, and NEVER
//      the event's in-memory displayName (R1-4);
//   3. the read providers return EMPTY for a non-manager role and DATA for a
//      manager (the read-gate isManager, R1-5).

import 'package:buildsmart/screens/intel/intel_tab.dart';
import 'package:buildsmart/screens/manager_dashboard_screen.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/intel/intel_event.dart';
import 'package:buildsmart/state/intel/intel_events.dart';
import 'package:buildsmart/state/intel/intel_log.dart';
import 'package:buildsmart/state/intel/intel_read.dart';
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

  // A hand-built demo batch: session s1 (uid u1) converts through the whole
  // funnel; session s2 (actorKey a2) drops after product_view. Both are FRESH
  // (< kHeartbeat*2.5 = 75 s) so both are "live" for presence. The first event
  // carries a displayName — the R1-4 canary that must NEVER render.
  List<IntelEvent> demoEvents(DateTime now) {
    DateTime ago(int s) => now.subtract(Duration(seconds: s));
    return <IntelEvent>[
      IntelEvent(
        name: IntelEvents.searchSubmit,
        at: ago(50),
        uid: 'u1',
        sessionId: 's1',
        screen: 'search',
        displayName: 'סוד-פרטי', // R1-4 canary — must never reach the UI
      ),
      IntelEvent(
        name: IntelEvents.productView,
        at: ago(40),
        uid: 'u1',
        sessionId: 's1',
        screen: 'product',
      ),
      IntelEvent(
        name: IntelEvents.addToCart,
        at: ago(30),
        uid: 'u1',
        sessionId: 's1',
        screen: 'product',
      ),
      IntelEvent(
        name: IntelEvents.cartView,
        at: ago(20),
        uid: 'u1',
        sessionId: 's1',
        screen: 'cart',
      ),
      IntelEvent(
        name: IntelEvents.checkoutStart,
        at: ago(10),
        uid: 'u1',
        sessionId: 's1',
        screen: 'checkout',
      ),
      IntelEvent(
        name: IntelEvents.orderPlaced,
        at: ago(2),
        uid: 'u1',
        sessionId: 's1',
        screen: 'checkout',
      ),
      IntelEvent(
        name: IntelEvents.searchSubmit,
        at: ago(45),
        actorKey: 'a2',
        sessionId: 's2',
        screen: 'search',
      ),
      IntelEvent(
        name: IntelEvents.productView,
        at: ago(35),
        actorKey: 'a2',
        sessionId: 's2',
        screen: 'product',
      ),
    ];
  }

  // Deterministic boardAuth override — a real (non-async-load) session for the
  // gate tests. `loginManagerViaGoogle` / `enterDemo` set state synchronously.
  Override boardAuthAs(BoardRole? role) =>
      boardAuthProvider.overrideWith((ref) {
        final n = BoardAuthNotifier(ref, bindFirebase: false);
        if (role == BoardRole.manager) {
          n.loginManagerViaGoogle(uid: 'mgr-test', displayName: 'מנהל');
        } else if (role != null) {
          n.enterDemo(role);
        }
        return n;
      });

  group('step 98 · flag-OFF invariant — 4 tabs, no 📡 intel tab', () {
    testWidgets('the dashboard shows the verbatim 4 tabs; tabCount == 4; the 📡 '
        'tab is absent (kIntelLive const-false)', (t) async {
      SharedPreferences.setMockInitialValues({
        'bs.board-auth.v1':
            '{"role":"manager","username":"admin","displayName":"מנהל המערכת","demo":false}',
      });
      await t.binding.setSurfaceSize(const Size(440, 950));
      addTearDown(() => t.binding.setSurfaceSize(null));
      await t.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            locale: Locale('he'),
            home: ManagerDashboardScreen(),
          ),
        ),
      );
      await settle(t);

      // tabCount is DERIVED from `_kManagerTabs.length` — 4 with the flag off.
      expect(ManagerDashboardScreen.tabCount, 4);

      // The four verbatim labels are unchanged.
      for (final label in const ['לוח בקרה', 'הזמנות', 'לקוחות', 'ניהול']) {
        expect(find.text(label), findsWidgets, reason: 'tab $label missing');
      }

      // No 5th tab — neither the toggle label nor the tab widget exists (even
      // off-stage in the IndexedStack).
      expect(find.text('מודיעין לקוחות'), findsNothing);
      expect(find.text('מודיעין לקוחות', skipOffstage: false), findsNothing);
      expect(find.byType(IntelTab), findsNothing);
      expect(find.byType(IntelTab, skipOffstage: false), findsNothing);
    });
  });

  group('step 98 · IntelTab widget (RTL · a11y · folded demo data)', () {
    testWidgets('renders under Directionality(rtl), carries a Semantics label, '
        'shows folded demo data, and never the event displayName (R1-4)',
        (t) async {
      SharedPreferences.setMockInitialValues({
        'bs.board-auth.v1':
            '{"role":"manager","username":"admin","displayName":"מנהל המערכת","demo":false}',
      });
      await t.binding.setSurfaceSize(const Size(440, 950));
      addTearDown(() => t.binding.setSurfaceSize(null));

      final container = ProviderContainer();
      addTearDown(container.dispose);
      // Seed the ring buffer BEFORE the first data build.
      final notifier = container.read(intelLogProvider.notifier);
      for (final e in demoEvents(DateTime.now())) {
        notifier.record(e);
      }

      await t.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            locale: Locale('he'),
            home: Scaffold(body: IntelTab()),
          ),
        ),
      );
      await settle(t); // let boardAuth._load resolve to the manager session

      // (a) RTL — IntelTab wraps its content in a rtl Directionality.
      final dir = t.widget<Directionality>(
        find
            .descendant(
              of: find.byType(IntelTab),
              matching: find.byType(Directionality),
            )
            .first,
      );
      expect(dir.textDirection, TextDirection.rtl);

      // (b) Semantics — the intro carries an explicit label.
      final labelled = t
          .widgetList<Semantics>(find.byType(Semantics))
          .where((s) => s.properties.label == 'מודיעין לקוחות');
      expect(labelled, isNotEmpty, reason: 'no Semantics(label:) surface');

      // (c) The four folded sections render.
      expect(find.text('משפך המרה'), findsOneWidget);
      expect(find.text('פלחי לקוחות'), findsOneWidget);
      expect(find.text('שימור לקוחות'), findsOneWidget);
      expect(find.text('מי מחובר כעת'), findsOneWidget);

      // (d) Demo funnel data folded from the seed: the top stage + the biggest
      // drop-off (product_view → add_to_cart, the one seeded loss).
      expect(find.text('חיפוש'), findsWidgets);
      expect(find.textContaining('הנשירה הגדולה'), findsOneWidget);

      // (e) R1-4 — the event's in-memory displayName NEVER renders.
      expect(find.text('סוד-פרטי'), findsNothing);
      expect(find.text('סוד-פרטי', skipOffstage: false), findsNothing);
      expect(find.textContaining('סוד'), findsNothing);
    });

    testWidgets('constructs directly (kIntelLive-independent) with an empty '
        'buffer → honest empty states, no crash', (t) async {
      SharedPreferences.setMockInitialValues({
        'bs.board-auth.v1':
            '{"role":"manager","username":"admin","displayName":"מנהל המערכת","demo":false}',
      });
      await t.binding.setSurfaceSize(const Size(440, 950));
      addTearDown(() => t.binding.setSurfaceSize(null));
      await t.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            locale: Locale('he'),
            home: Scaffold(body: IntelTab()),
          ),
        ),
      );
      await settle(t);
      // The surface still builds (headers present); presence shows its empty line.
      expect(find.text('מי מחובר כעת'), findsOneWidget);
      expect(find.text('אף לקוח לא מחובר כעת'), findsOneWidget);
    });
  });

  group('step 98 · read providers gate on isManager (R1-5)', () {
    test('empty for a non-manager role, data for a manager', () {
      SharedPreferences.setMockInitialValues({});
      final now = DateTime.now();

      // Non-manager (worker board) → every read surface is empty.
      final worker =
          ProviderContainer(overrides: [boardAuthAs(BoardRole.worker)]);
      addTearDown(worker.dispose);
      for (final e in demoEvents(now)) {
        worker.read(intelLogProvider.notifier).record(e);
      }
      expect(worker.read(intelSegmentsProvider), isEmpty);
      expect(worker.read(intelRetentionProvider), isEmpty);
      expect(worker.read(intelPresenceProvider), isEmpty);
      expect(
        worker.read(intelInsightsProvider).funnel.biggestDropOff,
        isNull,
        reason: 'a non-manager funnel folds no events',
      );

      // Manager board → data (the manager-independent surfaces prove the gate;
      // presence is proven fully in the widget test above).
      final mgr =
          ProviderContainer(overrides: [boardAuthAs(BoardRole.manager)]);
      addTearDown(mgr.dispose);
      for (final e in demoEvents(now)) {
        mgr.read(intelLogProvider.notifier).record(e);
      }
      expect(mgr.read(intelSegmentsProvider), isNotEmpty);
      expect(mgr.read(intelRetentionProvider), isNotEmpty);
      expect(
        mgr.read(intelInsightsProvider).funnel.biggestDropOff,
        isNotNull,
        reason: 'a manager funnel folds the seeded events',
      );
    });

    test('presence rows resolve names OWNER-SIDE (never the event displayName), '
        'customer-only (anonymous excluded)', () {
      SharedPreferences.setMockInitialValues({});
      final now = DateTime.now();
      final mgr =
          ProviderContainer(overrides: [boardAuthAs(BoardRole.manager)]);
      addTearDown(mgr.dispose);

      // A fully-anonymous event (no uid, no actorKey) carrying a displayName —
      // it must NOT become a presence row (customer-only, R1-5), and its
      // displayName must NEVER surface as a name (R1-4).
      mgr.read(intelLogProvider.notifier).record(
            IntelEvent(
              name: IntelEvents.searchSubmit,
              at: now,
              sessionId: 'anon-1',
              screen: 'search',
              displayName: 'סוד-פרטי',
            ),
          );
      // Two identified customers, fresh → two live rows.
      for (final e in demoEvents(now)) {
        mgr.read(intelLogProvider.notifier).record(e);
      }

      final rows = mgr.read(intelPresenceProvider);
      // The identified customers are present; the anonymous actor is excluded.
      expect(rows.map((r) => r.key), containsAll(<String>['u1', 'a2']));
      expect(rows.any((r) => r.key == '__anon__'), isFalse);
      // Names come owner-side (null today — the derived aggregate has no customer
      // uid), NEVER from the event displayName.
      for (final r in rows) {
        expect(r.name, isNot('סוד-פרטי'));
      }
    });
  });
}
