// Studio Pillar-3 · step 99 (PART A) — the per-customer JOURNEY TIMELINE
// (`JourneyTimeline` + the pure journey helpers). Covers §5:
//   1. flag-OFF invariant — with `kIntelLive` const-false (the compile default in
//      tests) the customer detail sheet shows NO "מסע הלקוח" section and NO
//      `JourneyTimeline` widget (even off-stage) → the sheet is BYTE-IDENTICAL to
//      today;
//   2. the widget (constructed directly, kIntelLive-independent) renders a seeded
//      customer's events JOINED BY uid/actorKey, newest-first, with the Hebrew
//      labels + the stuck highlight (the reused `_StagePill` "תקוע");
//   3. JOIN-BY-UID, SAME-NAME-SEPARATE — two customers with the SAME display name
//      but DIFFERENT keys each see only their OWN events (no cross-contamination):
//      the R2-#12 proof at the UI layer, both directions;
//   4. an event's in-memory `displayName` is NEVER rendered as the customer name
//      (R1-4 — owner-side only);
//   5. the pure folds (`journeyEventsFor` / `journeyRowStuck` / `journeyConverted`
//      / the he-map) enforce the same rules unit-side.

import 'package:buildsmart/screens/intel/journey_labels.dart';
import 'package:buildsmart/screens/manager_dashboard_screen.dart'
    show JourneyTimeline, ManagerDashboardScreen;
import 'package:buildsmart/state/intel/intel_event.dart';
import 'package:buildsmart/state/intel/intel_events.dart';
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

  // BOTH customers carry the SAME display name but DIFFERENT stable keys:
  //   • u1 — a CONVERTING journey (ends in order_placed → its checkout is NOT
  //     stuck);
  //   • u2 — the SAME name, a STUCK journey (search_no_result + an un-converted
  //     checkout_start).
  // Every event carries the display name as its in-memory `displayName` — the R1-4
  // canary that must NEVER surface in the UI (names are owner-side only).
  const kSharedName = 'משה כהן';
  List<IntelEvent> seed(DateTime now) {
    DateTime ago(int s) => now.subtract(Duration(seconds: s));
    return <IntelEvent>[
      // u1 — converting.
      IntelEvent(
        name: IntelEvents.screenView,
        at: ago(300),
        uid: 'u1',
        screen: 'home',
        displayName: kSharedName,
      ),
      IntelEvent(
        name: IntelEvents.searchSubmit,
        at: ago(240),
        uid: 'u1',
        screen: 'search',
        displayName: kSharedName,
      ),
      IntelEvent(
        name: IntelEvents.addToCart,
        at: ago(180),
        uid: 'u1',
        screen: 'product',
        displayName: kSharedName,
      ),
      IntelEvent(
        name: IntelEvents.checkoutStart,
        at: ago(120),
        uid: 'u1',
        screen: 'checkout',
        displayName: kSharedName,
      ),
      IntelEvent(
        name: IntelEvents.orderPlaced,
        at: ago(60),
        uid: 'u1',
        screen: 'checkout',
        displayName: kSharedName,
      ),
      // u2 — SAME name, DIFFERENT key, stuck.
      IntelEvent(
        name: IntelEvents.searchNoResult,
        at: ago(90),
        uid: 'u2',
        screen: 'search',
        displayName: kSharedName,
      ),
      IntelEvent(
        name: IntelEvents.checkoutStart,
        at: ago(30),
        uid: 'u2',
        screen: 'checkout',
        displayName: kSharedName,
      ),
    ];
  }

  Widget host(Widget child) => MaterialApp(
        locale: const Locale('he'),
        home: Scaffold(body: SingleChildScrollView(child: child)),
      );

  group('step 99A · flag-OFF invariant — no journey section (byte-identical)', () {
    testWidgets('the customer detail sheet shows NO "מסע הלקוח" section and NO '
        'JourneyTimeline (kIntelLive const-false)', (t) async {
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

      // Open the 👥 לקוחות tab, then a customer's detail sheet.
      await t.tap(find.text('לקוחות').first);
      await settle(t);
      await t.tap(find.text('משה אברהם'));
      await settle(t);

      // Sanity — the sheet is really open (its credit rows are on screen).
      expect(find.text('מסגרת אשראי'), findsOneWidget);

      // The journey section + widget are tree-shaken out — absent even off-stage.
      expect(find.byType(JourneyTimeline), findsNothing);
      expect(find.byType(JourneyTimeline, skipOffstage: false), findsNothing);
      expect(find.textContaining('מסע הלקוח'), findsNothing);
      expect(
        find.textContaining('מסע הלקוח', skipOffstage: false),
        findsNothing,
      );
    });
  });

  group('step 99A · JourneyTimeline widget (join-by-key · newest-first · labels · '
      'stuck)', () {
    testWidgets('customer u1 — its OWN converting journey, newest-first, Hebrew '
        'labels; NOT u2 events; converted checkout NOT highlighted; displayName '
        'never rendered', (t) async {
      final now = DateTime.now();
      await t.binding.setSurfaceSize(const Size(440, 950));
      addTearDown(() => t.binding.setSurfaceSize(null));
      await t.pumpWidget(
        host(JourneyTimeline(customerKey: 'u1', events: seed(now), now: now)),
      );
      await t.pump();

      // The section header renders.
      expect(find.text('🧭 מסע הלקוח'), findsOneWidget);

      // u1's Hebrew labels (spec-verbatim) all present.
      for (final label in const [
        'צפייה במסך', // screen_view
        'חיפוש', // search_submit
        'הוספה לסל', // add_to_cart
        'התחלת תשלום', // checkout_start
        'הזמנה בוצעה', // order_placed
      ]) {
        expect(find.text(label), findsOneWidget, reason: 'u1 label $label');
      }

      // JOIN-BY-KEY — u2's dead-end label is NOT here (no cross-contamination).
      expect(find.text('חיפוש ללא תוצאות'), findsNothing);

      // Newest-first — order_placed (ago 60) sits ABOVE screen_view (ago 300).
      expect(
        t.getTopLeft(find.text('הזמנה בוצעה')).dy,
        lessThan(t.getTopLeft(find.text('צפייה במסך')).dy),
        reason: 'timeline must be newest-first',
      );

      // u1 CONVERTED → its checkout_start is NOT a stuck row → no "תקוע" pill.
      expect(find.text('תקוע'), findsNothing);

      // R1-4 — the event displayName NEVER renders as the customer name.
      expect(find.text(kSharedName), findsNothing);
      expect(find.text(kSharedName, skipOffstage: false), findsNothing);
    });

    testWidgets('customer u2 — SAME name, DIFFERENT key: its OWN stuck journey '
        'with the reused _StagePill "תקוע" highlight; NOT u1 events', (t) async {
      final now = DateTime.now();
      await t.binding.setSurfaceSize(const Size(440, 950));
      addTearDown(() => t.binding.setSurfaceSize(null));
      await t.pumpWidget(
        host(JourneyTimeline(customerKey: 'u2', events: seed(now), now: now)),
      );
      await t.pump();

      // u2's own labels.
      expect(find.text('חיפוש ללא תוצאות'), findsOneWidget); // search_no_result
      expect(find.text('התחלת תשלום'), findsOneWidget); // checkout_start

      // JOIN-BY-KEY — u1's terminal conversion is NOT here.
      expect(find.text('הזמנה בוצעה'), findsNothing);

      // STUCK highlight — both u2 rows are stuck (dead-end search + un-converted
      // checkout) → two "תקוע" pills.
      expect(find.text('תקוע'), findsNWidgets(2));

      // R1-4 — displayName never rendered.
      expect(find.text(kSharedName), findsNothing);
    });

    testWidgets('null key → honest no-key empty state; unknown key → honest '
        'no-activity empty state (never a name-join fallback)', (t) async {
      final now = DateTime.now();
      await t.binding.setSurfaceSize(const Size(440, 950));
      addTearDown(() => t.binding.setSurfaceSize(null));

      // No resolvable key (the derived ManagerCustomer today) → the no-key line.
      await t.pumpWidget(
        host(JourneyTimeline(customerKey: null, events: seed(now), now: now)),
      );
      await t.pump();
      expect(find.textContaining('אין מזהה לקוח לשיוך'), findsOneWidget);
      expect(find.text('תקוע'), findsNothing);

      // A key with no matching events → the no-activity line (NOT a name join).
      await t.pumpWidget(
        host(JourneyTimeline(customerKey: 'ghost', events: seed(now), now: now)),
      );
      await t.pump();
      expect(find.textContaining('אין פעילות מתועדת'), findsOneWidget);
    });
  });

  group('step 99A · pure journey folds', () {
    test('journeyEventsFor JOINS BY KEY (same name, disjoint), newest-first, '
        'window-capped; null/empty key → empty', () {
      final now = DateTime.now();
      final events = seed(now);

      final u1 = journeyEventsFor(events, 'u1');
      final u2 = journeyEventsFor(events, 'u2');

      // Disjoint — each key sees ONLY its own events (R2-#12, same shared name).
      expect(u1.length, 5);
      expect(u2.length, 2);
      expect(u1.every((e) => e.uid == 'u1'), isTrue);
      expect(u2.every((e) => e.uid == 'u2'), isTrue);
      expect(u1.any((e) => e.uid == 'u2'), isFalse);

      // Newest-first.
      expect(u1.first.name, IntelEvents.orderPlaced);
      expect(u1.last.name, IntelEvents.screenView);

      // No key resolvable → empty (the honest no-join path).
      expect(journeyEventsFor(events, null), isEmpty);
      expect(journeyEventsFor(events, ''), isEmpty);

      // Window cap holds.
      final many = <IntelEvent>[
        for (var i = 0; i < kJourneyWindow + 20; i++)
          IntelEvent(
            name: IntelEvents.screenView,
            at: now.subtract(Duration(seconds: i)),
            uid: 'big',
          ),
      ];
      expect(journeyEventsFor(many, 'big').length, kJourneyWindow);
    });

    test('journeyConverted + journeyRowStuck rules', () {
      final now = DateTime.now();
      final events = seed(now);
      expect(journeyConverted(journeyEventsFor(events, 'u1')), isTrue);
      expect(journeyConverted(journeyEventsFor(events, 'u2')), isFalse);

      IntelEvent ev(String name) => IntelEvent(name: name, at: now, uid: 'x');
      // A dead-end search is always stuck.
      expect(
        journeyRowStuck(ev(IntelEvents.searchNoResult), converted: true),
        isTrue,
      );
      // An un-converted checkout is stuck; a converted one is not.
      expect(
        journeyRowStuck(ev(IntelEvents.checkoutStart), converted: false),
        isTrue,
      );
      expect(
        journeyRowStuck(ev(IntelEvents.checkoutStart), converted: true),
        isFalse,
      );
      // A normal step is never stuck.
      expect(
        journeyRowStuck(ev(IntelEvents.orderPlaced), converted: false),
        isFalse,
      );
    });

    test('the he-map honors the spec labels (keyed by the IntelEvents wire names)',
        () {
      expect(intelEventHe(IntelEvents.screenView), 'צפייה במסך');
      expect(intelEventHe(IntelEvents.searchSubmit), 'חיפוש');
      expect(intelEventHe(IntelEvents.addToCart), 'הוספה לסל');
      expect(intelEventHe(IntelEvents.checkoutStart), 'התחלת תשלום');
      expect(intelEventHe(IntelEvents.orderPlaced), 'הזמנה בוצעה');
      // Every taxonomy name has a label + an emoji (no bare fallbacks leak).
      for (final n in IntelEvents.all) {
        expect(intelEventHe(n), isNot(n), reason: 'missing he label for $n');
        expect(intelEventEmoji(n), isNot('•'), reason: 'missing emoji for $n');
      }
    });
  });
}
