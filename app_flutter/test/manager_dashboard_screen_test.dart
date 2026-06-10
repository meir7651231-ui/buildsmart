// M1 — widget coverage of the 👔 manager dashboard SHELL (`ManagerDashboardScreen`).
// Asserts: (1) the screen BUILDS as a LIGHT full-role-app frame (bgLight scaffold +
// white AppBar + the "מרכז השליטה" / "מנהל המערכת" titles + a "חי" pill), (2) the
// 4-tab segmented toggle SWITCHES the IndexedStack body (tab placeholders are
// "בקרוב" this wave), and (3) the manager entry in the role picker ("מי אתה?" →
// מנהל המערכת) OPENS this screen via Navigator.push — instead of the old BS-dial
// drill. Tabs are PLACEHOLDERS (M2–M5 fill them).

import 'package:buildsmart/data/brands.dart';
import 'package:buildsmart/logic/manager_dashboard.dart';
import 'package:buildsmart/screens/home_shell.dart';
import 'package:buildsmart/screens/manager_dashboard_screen.dart';
import 'package:buildsmart/screens/regression_panel_screen.dart';
import 'package:buildsmart/screens/role_picker_sheet.dart';
import 'package:buildsmart/state/manager_dashboard_state.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:buildsmart/theme/tokens.dart';
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

  Future<ProviderContainer> pumpScreen(WidgetTester t) async {
    SharedPreferences.setMockInitialValues({
      // #65 gate: seed a board session so the board (not the gate) renders.
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
    return ProviderScope.containerOf(
      t.element(find.byType(ManagerDashboardScreen)),
    );
  }

  group('manager dashboard SHELL (M1)', () {
    testWidgets('builds as a LIGHT frame — bgLight scaffold, white AppBar, '
        'title + subtitle + "חי" pill', (t) async {
      await pumpScreen(t);

      // Light scaffold.
      final scaffold = t.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, BsTokens.bgLight);

      // White AppBar (cardLight) with dark title text.
      final appBar = t.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, BsTokens.cardLight);

      // Title + subtitle + the live pill text.
      expect(find.text('מרכז השליטה'), findsOneWidget);
      expect(find.text('מנהל המערכת'), findsOneWidget);
      expect(find.text('חי'), findsOneWidget);
    });

    testWidgets('the 4 tab pills are present (verbatim labels)', (t) async {
      await pumpScreen(t);
      for (final label in const ['לוח בקרה', 'הזמנות', 'לקוחות', 'ניהול']) {
        expect(find.text(label), findsWidgets, reason: 'tab $label missing');
      }
    });

    testWidgets('tapping a tab pill switches the IndexedStack (managerTabProvider)',
        (t) async {
      final c = await pumpScreen(t);
      // Default tab = 0 (לוח בקרה).
      expect(c.read(managerTabProvider), 0);

      // Every placeholder body lives in the IndexedStack, so all four labels are
      // in the tree; assert the active INDEX changes when each pill is tapped.
      Future<void> tapTab(String label, int expected) async {
        await t.tap(find.text(label).first);
        await settle(t);
        expect(
          c.read(managerTabProvider),
          expected,
          reason: 'tapping $label should activate index $expected',
        );
      }

      await tapTab('הזמנות', 1);
      await tapTab('לקוחות', 2);
      await tapTab('ניהול', 3);
      await tapTab('לוח בקרה', 0);

      // The IndexedStack reflects the active tab.
      final stack = t.widget<IndexedStack>(find.byType(IndexedStack));
      expect(stack.index, 0);
    });

    testWidgets('the manager screen is COMPLETE — NO "בקרוב" placeholder remains '
        'anywhere (all 4 tabs are real after M5)', (t) async {
      await pumpScreen(t);
      // Every tab is now built (📊 M2 · 🚚 M3 · 👥 M4 · 🛠️ M5). The IndexedStack
      // keeps the other three mounted OFFSTAGE, so even a `skipOffstage:false`
      // search must find ZERO "בקרוב" — the placeholder class is gone entirely.
      expect(find.text('בקרוב'), findsNothing);
      expect(find.text('בקרוב', skipOffstage: false), findsNothing);
    });

    testWidgets('route() pushes the screen', (t) async {
      SharedPreferences.setMockInitialValues({
      // #65 gate: seed a board session so the board (not the gate) renders.
      'bs.board-auth.v1':
          '{"role":"manager","username":"admin","displayName":"מנהל המערכת","demo":false}',
    });
      await t.binding.setSurfaceSize(const Size(440, 950));
      addTearDown(() => t.binding.setSurfaceSize(null));
      await t.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('he'),
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).push(ManagerDashboardScreen.route()),
                    child: const Text('go'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await settle(t);
      expect(find.byType(ManagerDashboardScreen), findsNothing);
      await t.tap(find.text('go'));
      await settle(t);
      expect(find.byType(ManagerDashboardScreen), findsOneWidget);
    });
  });

  group('📊 לוח בקרה — dashboard cockpit (M2, LIVE engine)', () {
    testWidgets('the 5 mdMetric tiles render their LIVE numbers '
        '(verbatim labels) — sourced from the engine analytics', (t) async {
      final c = await pumpScreen(t);
      final a = c.read(managerAnalyticsProvider);

      // The five verbatim tile labels (default tab 0 = 📊 is onstage).
      for (final label in const [
        'הזמנות פתוחות',
        'מוצרים בקטלוג',
        'אביזרים נלווים',
        'זמינים כעת',
        'חנויות פעילות',
      ]) {
        expect(find.text(label), findsOneWidget, reason: 'tile $label missing');
      }

      // Each tile shows the LIVE number the analytics provider derives over the
      // engine's orders — NOT a hard-coded literal. With the seed: 4 / 54 / 148
      // / 202 / 3/3 (asserted via the provider so the test tracks the engine).
      // 📦 catalog == every non-accessory product (the verbatim index.html
      // distribution), i.e. total − accessories.
      expect(a.openOrders, 4, reason: 'seed open-orders');
      expect(a.catalogCount, a.totalProducts - a.accessoryCount);
      expect(a.catalogCount, 54, reason: 'seed catalog count (202 − 148)');
      expect(find.text('${a.openOrders}'), findsWidgets);
      expect(find.text('${a.catalogCount}'), findsWidgets);
      expect(find.text('${a.accessoryCount}'), findsWidgets);
      expect(find.text('${a.availableCount}'), findsWidgets);
      expect(find.text(a.storesLabel), findsOneWidget); // "3/3"
    });

    testWidgets('the order pipeline shows a per-stage count across the 6 '
        'kManagerOrderFlow stages (live engine)', (t) async {
      final c = await pumpScreen(t);
      final orders = c.read(ordersEngineProvider);

      // Section header + the 6 verbatim pipeline labels.
      expect(find.text('צינור ההזמנות'), findsOneWidget);
      for (final label in const [
        'התקבלה',
        'בהכנה',
        'מוכן',
        'נאסף',
        'בדרך',
        'נמסר',
      ]) {
        expect(
          find.text(label),
          findsOneWidget,
          reason: 'pipeline stage $label missing',
        );
      }

      // Per-stage counts equal the live engine's group-by-stage. Seed stages:
      // new/preparing/ready/transit (one each) → 1/1/1/0/0/1.
      for (final stage in kManagerOrderFlow) {
        final n = orders.where((o) => o.stage == stage).length;
        expect(
          find.text('$n'),
          findsWidgets,
          reason: 'stage $stage count $n should render',
        );
      }
      // The seed has none in pickup/delivered → those rows show 0.
      expect(orders.where((o) => o.stage == 'pickup').length, 0);
      expect(orders.where((o) => o.stage == 'delivered').length, 0);
    });

    testWidgets('the tab is LIVE — placing an order reflows the 🚚 tile + the '
        'pipeline (engine read, not the static const)', (t) async {
      final c = await pumpScreen(t);

      // Baseline: 4 open orders, 1 "new"/התקבלה.
      expect(c.read(managerAnalyticsProvider).openOrders, 4);

      // Place a NEW order on the shared engine (any role could do this).
      c.read(ordersEngineProvider.notifier).placeOrder(
            who: 'בודק חי',
            site: 'אתר בדיקה',
            items: 2,
            sum: 999,
          );
      await settle(t);

      // The 🚚 open-orders tile and the התקבלה pipeline row both recount.
      expect(c.read(managerAnalyticsProvider).openOrders, 5);
      final newCount = c
          .read(ordersEngineProvider)
          .where((o) => o.stage == 'new')
          .length;
      expect(newCount, 2);
      expect(find.text('5'), findsWidgets); // 🚚 tile now reads 5
    });

    testWidgets('the cockpit is LIGHT — white tile/pipeline cards on bgLight, '
        'NO dark tokens', (t) async {
      await pumpScreen(t);

      // The scaffold + the tile/pipeline cards are the LIGHT tokens.
      final scaffold = t.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, BsTokens.bgLight);

      // Every Container with a solid BoxDecoration colour in the cockpit body is
      // a LIGHT surface — none uses a dark token (bgDark/cardDark/inkDark).
      final decos = t
          .widgetList<Container>(find.byType(Container))
          .map((w) => w.decoration)
          .whereType<BoxDecoration>()
          .map((d) => d.color)
          .whereType<Color>()
          .toList();
      for (final dark in const [
        BsTokens.bgDark,
        BsTokens.cardDark,
        BsTokens.inkDark,
        BsTokens.mutedDark,
      ]) {
        expect(decos, isNot(contains(dark)), reason: 'dark token $dark leaked');
      }
      // At least the metric tiles + the pipeline card are white cardLight.
      expect(
        decos.where((c) => c == BsTokens.cardLight).length,
        greaterThanOrEqualTo(6),
      );
    });
  });

  group('🚚 הזמנות — live order control center (M3, god-mode advance)', () {
    // Switch to the 🚚 הזמנות tab by tapping its toggle pill. `.first` selects
    // the toggle pill (built above the IndexedStack body) even after the tab's
    // own 'הזמנות' summary label mounts.
    Future<void> openOrdersTab(WidgetTester t) async {
      await t.tap(find.text('הזמנות').first);
      await settle(t);
    }

    testWidgets('renders the seed orders grouped by their stage — each row '
        'shows 📦 id, who·site, items·₪sum, and the stage pill', (t) async {
      final c = await pumpScreen(t);
      await openOrdersTab(t);
      expect(c.read(managerTabProvider), 1);

      // Every seed order's id + the who·site line are on screen.
      for (final o in c.read(ordersEngineProvider)) {
        expect(find.text('📦 ${o.id}'), findsOneWidget, reason: '${o.id} row');
        expect(
          find.text('${o.who} · ${o.site}'),
          findsOneWidget,
          reason: '${o.id} who·site',
        );
      }

      // The 3-stat summary (total / open / revenue), verbatim labels.
      expect(find.text('פתוחות'), findsOneWidget);
      expect(find.text('מחזור'), findsOneWidget);
      // 4 seed orders, all open; revenue = 1240+680+3150+420 = 5490.
      expect(find.text('4'), findsWidgets); // total
      expect(find.text('₪5,490'), findsOneWidget); // grouped revenue

      // The stage pills use the VERBATIM ORDER_STAGE labels (full forms, distinct
      // from the dashboard's short pipeline labels). Seed stages: new/preparing/
      // ready/transit — each present exactly once as a row pill.
      for (final label in const [
        'התקבלה',
        'בהכנה',
        'מוכן לאיסוף',
        'בדרך לאתר',
      ]) {
        expect(find.text(label), findsWidgets, reason: 'stage pill $label');
      }
    });

    testWidgets('the stage filter chips narrow the list to one stage', (t) async {
      final c = await pumpScreen(t);
      await openOrdersTab(t);

      // The "הכל (4)" chip plus one chip per populated stage. Tapping a stage
      // chip filters to just that stage's order(s).
      expect(find.text('הכל (4)'), findsOneWidget);

      // Filter to בהכנה (preparing) — only BS-1041 (אבי מזרחי) remains.
      await t.tap(find.text('בהכנה (1)'));
      await settle(t);
      expect(find.text('📦 BS-1041'), findsOneWidget);
      expect(find.text('📦 BS-1042'), findsNothing); // a `new` order, filtered out
      expect(find.text('📦 BS-1040'), findsNothing); // a `ready` order, filtered out

      // Back to הכל — all four return.
      await t.tap(find.text('הכל (4)'));
      await settle(t);
      for (final o in c.read(ordersEngineProvider)) {
        expect(find.text('📦 ${o.id}'), findsOneWidget);
      }
    });

    testWidgets('tapping "קדם שלב ›" advances that order one stage on the engine',
        (t) async {
      final c = await pumpScreen(t);
      await openOrdersTab(t);

      // BS-1042 starts `new` (התקבלה).
      expect(
        c.read(ordersEngineProvider).firstWhere((o) => o.id == 'BS-1042').stage,
        'new',
      );

      // Advance BS-1042: tap the "קדם שלב ›" button inside its row.
      final advanceInRow = find.descendant(
        of: find.ancestor(
          of: find.text('📦 BS-1042'),
          matching: find.byType(InkWell),
        ),
        matching: find.text('קדם שלב ›'),
      );
      await t.ensureVisible(advanceInRow.first);
      await settle(t);
      await t.tap(advanceInRow.first);
      await settle(t);

      // The engine moved it new → preparing.
      expect(
        c.read(ordersEngineProvider).firstWhere((o) => o.id == 'BS-1042').stage,
        'preparing',
      );
    });

    testWidgets('a delivered order shows "✓ הושלם" instead of the advance button '
        'and advancing it is a no-op', (t) async {
      final c = await pumpScreen(t);
      // God-step BS-1042 straight to delivered on the shared engine.
      c.read(ordersEngineProvider.notifier).setStage('BS-1042', 'delivered');
      await openOrdersTab(t);
      await settle(t);

      // Its row now shows the completed badge.
      expect(find.text('✓ הושלם'), findsWidgets);
      expect(
        c.read(ordersEngineProvider).firstWhere((o) => o.id == 'BS-1042').stage,
        'delivered',
      );
    });

    testWidgets('KEYSTONE — advancing in 🚚 reflows the 📊 dashboard LIVE '
        '(shared engine: tile + pipeline recount)', (t) async {
      final c = await pumpScreen(t);

      // Baseline on the 📊 dashboard (default tab 0): 4 open, BS-1039 is the only
      // order in transit (בדרך). Drive it to delivered from the 🚚 tab and watch
      // the dashboard's 🚚 open-orders tile drop 4 → 3.
      expect(c.read(managerAnalyticsProvider).openOrders, 4);
      final deliveredBefore = c
          .read(ordersEngineProvider)
          .where((o) => o.stage == 'delivered')
          .length;
      expect(deliveredBefore, 0);

      await openOrdersTab(t);

      // BS-1039 is in transit — one advance lands it on delivered.
      expect(
        c.read(ordersEngineProvider).firstWhere((o) => o.id == 'BS-1039').stage,
        'transit',
      );
      // BS-1039 is the bottom (4th) seed row — scroll its advance button into
      // view, then tap it (the row's outer card InkWell holds the id text; the
      // advance text lives inside its own button InkWell).
      final advanceInRow = find.descendant(
        of: find.ancestor(
          of: find.text('📦 BS-1039'),
          matching: find.byType(InkWell),
        ),
        matching: find.text('קדם שלב ›'),
      );
      await t.ensureVisible(advanceInRow.first);
      await settle(t);
      await t.tap(advanceInRow.first);
      await settle(t);

      // The SHARED engine is now: BS-1039 delivered → open drops to 3, delivered
      // rises to 1. The 📊 dashboard reads the SAME providers, so its numbers
      // reflow without any extra action.
      expect(
        c.read(ordersEngineProvider).firstWhere((o) => o.id == 'BS-1039').stage,
        'delivered',
      );
      expect(c.read(managerAnalyticsProvider).openOrders, 3);
      expect(
        c.read(ordersEngineProvider).where((o) => o.stage == 'delivered').length,
        1,
      );

      // Switch to the 📊 tab and confirm the live tile now reads 3.
      await t.tap(find.text('לוח בקרה').first);
      await settle(t);
      // 🚚 open-orders tile + the delivered pipeline row both reflect the engine.
      expect(find.text('3'), findsWidgets);
    });

    testWidgets('the orders tab is LIGHT — white rows on bgLight, NO dark tokens',
        (t) async {
      await pumpScreen(t);
      await openOrdersTab(t);

      final scaffold = t.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, BsTokens.bgLight);

      final decos = t
          .widgetList<Container>(find.byType(Container))
          .map((w) => w.decoration)
          .whereType<BoxDecoration>()
          .map((d) => d.color)
          .whereType<Color>()
          .toList();
      for (final dark in const [
        BsTokens.bgDark,
        BsTokens.cardDark,
        BsTokens.inkDark,
        BsTokens.mutedDark,
      ]) {
        expect(decos, isNot(contains(dark)), reason: 'dark token $dark leaked');
      }
    });
  });

  group('👥 לקוחות — live customer list + credit (M4)', () {
    // Switch to the 👥 לקוחות tab by tapping its toggle pill. `.first` selects
    // the toggle pill (built above the IndexedStack body) even after the tab's
    // own 'לקוחות'-derived labels mount.
    Future<void> openCustomersTab(WidgetTester t) async {
      await t.tap(find.text('לקוחות').first);
      await settle(t);
    }

    testWidgets('renders the live customers (grouped by buyer) — each card '
        'shows 👷 name, N הזמנות · M אתרים, and the credit-utilisation line',
        (t) async {
      final c = await pumpScreen(t);
      await openCustomersTab(t);
      expect(c.read(managerTabProvider), 2);

      // The customers come from the LIVE engine via managerCustomersProvider —
      // the four seed buyers, each with one order.
      final customers = c.read(managerCustomersProvider);
      expect(customers.length, 4);

      // Distinct sites per buyer, derived from the live orders exactly like the
      // tab does (the legacy `byName[nm].sites` set).
      final orders = c.read(ordersEngineProvider);
      for (final cust in customers) {
        // Each seed buyer's name renders on exactly one card (names are unique).
        expect(find.text(cust.name), findsOneWidget, reason: '${cust.name} card');
        // Their "N הזמנות · M אתרים" sub-line is present (the four seed buyers
        // all read "1 הזמנות · 1 אתרים", so this is findsWidgets, not one).
        final sites = orders
            .where((o) => o.who == cust.name)
            .map((o) => o.site)
            .toSet()
            .length;
        expect(
          find.text('${cust.orderCount} הזמנות · $sites אתרים'),
          findsWidgets,
          reason: '${cust.name} meta line',
        );

        // The verbatim credit line `ניצול אשראי: ₪used / ₪limit (pct%)` is
        // UNIQUE per customer (distinct spend/limit), so exactly one.
        final pct = cust.creditLimit == 0
            ? 0
            : ((cust.totalSpend / cust.creditLimit) * 100).round().clamp(0, 100);
        expect(
          find.text(
            'ניצול אשראי: ₪${_grp(cust.totalSpend)} / ₪${_grp(cust.creditLimit)} ($pct%)',
          ),
          findsOneWidget,
          reason: '${cust.name} credit line',
        );
      }

      // The 👷 avatar appears once per customer; the summary labels are present.
      expect(find.text('👷'), findsNWidgets(4));
      expect(find.text('קבלנים'), findsOneWidget);
      expect(find.text('סך רכש'), findsOneWidget);

      // Every seed buyer is under the credit ceiling → all "פעיל"; none high.
      expect(find.text('פעיל'), findsWidgets);
    });

    testWidgets('each card carries a credit-utilisation bar '
        '(LinearProgressIndicator at pct/100)', (t) async {
      final c = await pumpScreen(t);
      await openCustomersTab(t);

      // One bar per customer (4 seed customers). Each bar's value is the
      // customer's pct/100 — read off the provider so the test tracks the live
      // derivation, not a literal.
      final customers = c.read(managerCustomersProvider);
      final bars = t
          .widgetList<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          )
          .toList();
      expect(bars.length, customers.length);
      for (final bar in bars) {
        expect(bar.value, isNotNull);
        expect(bar.value, inInclusiveRange(0.0, 1.0));
      }
    });

    testWidgets('KEYSTONE — the tab is LIVE: placing a NEW contractor order on '
        'the engine ADDS a customer card', (t) async {
      final c = await pumpScreen(t);
      await openCustomersTab(t);

      // Baseline: the 4 seed customers; "בנאי חדש" is not among them.
      expect(c.read(managerCustomersProvider).length, 4);
      expect(find.text('בנאי חדש'), findsNothing);

      // A brand-new contractor places an order via the SHARED engine.
      c.read(ordersEngineProvider.notifier).placeOrder(
            who: 'בנאי חדש',
            site: 'אתר חדש',
            items: 3,
            sum: 1500,
          );
      await settle(t);

      // The customer list reflows LIVE — a 5th customer now exists and its card
      // is on screen (no manual refresh). Its UNIQUE credit line (spend 1500
      // against its own ceiling) renders, proving the new card mounted live.
      expect(c.read(managerCustomersProvider).length, 5);
      expect(find.text('בנאי חדש'), findsOneWidget);
      final fresh =
          c.read(managerCustomersProvider).firstWhere((x) => x.name == 'בנאי חדש');
      final freshPct = ((fresh.totalSpend / fresh.creditLimit) * 100)
          .round()
          .clamp(0, 100);
      expect(
        find.text(
          'ניצול אשראי: ₪${_grp(fresh.totalSpend)} / ₪${_grp(fresh.creditLimit)} ($freshPct%)',
        ),
        findsOneWidget,
      );
    });

    testWidgets('a contractor over 90% of their ceiling shows "⚠️ אשראי גבוה" '
        'and the אשראי גבוה filter narrows to them', (t) async {
      final c = await pumpScreen(t);

      // Push an EXISTING seed buyer (יוסי כהן) past 90% by placing an order
      // whose sum exceeds their whole credit ceiling → pct clamps to 100 → low.
      final ceiling = contractorCredit('יוסי כהן');
      c.read(ordersEngineProvider.notifier).placeOrder(
            who: 'יוסי כהן',
            site: 'מגדל הרצליה',
            items: 1,
            sum: ceiling, // total now > ceiling → pct = 100 ≥ 90 → status 'low'
          );
      await openCustomersTab(t);
      await settle(t);

      // The high-credit pill (with the ⚠️ glyph) is now on the יוסי כהן card.
      expect(find.text('⚠️ אשראי גבוה'), findsWidgets);

      // The status-filter chip row now offers an "אשראי גבוה (N)" chip; tapping
      // it narrows the list to the high-credit contractor(s) only.
      expect(find.textContaining('אשראי גבוה ('), findsOneWidget);
      await t.tap(find.textContaining('אשראי גבוה ('));
      await settle(t);
      expect(find.text('יוסי כהן'), findsOneWidget);
      // A still-active seed buyer (משה אברהם, low utilisation) is filtered out.
      expect(find.text('משה אברהם'), findsNothing);
    });

    testWidgets('tapping a customer card opens the detail sheet '
        '(limit / used / balance / sites + the contractor orders)', (t) async {
      await pumpScreen(t);
      await openCustomersTab(t);

      // Open משה אברהם's detail sheet (the top customer by spend, 3150).
      await t.tap(find.text('משה אברהם'));
      await settle(t);

      // The sheet's credit rows + the contractor's order id are on screen.
      expect(find.text('מסגרת אשראי'), findsOneWidget);
      expect(find.text('נוצל'), findsOneWidget);
      expect(find.text('יתרה זמינה'), findsOneWidget);
      expect(find.text('אתרי בנייה'), findsOneWidget);
      // משה אברהם owns the seed order BS-1040 — its row shows in the sheet.
      expect(find.text('ההזמנות של משה אברהם'), findsOneWidget);
      expect(find.text('📦 BS-1040'), findsWidgets);
    });

    testWidgets('the customers tab is LIGHT — white cards on bgLight, NO dark '
        'tokens', (t) async {
      await pumpScreen(t);
      await openCustomersTab(t);

      final scaffold = t.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, BsTokens.bgLight);

      final decos = t
          .widgetList<Container>(find.byType(Container))
          .map((w) => w.decoration)
          .whereType<BoxDecoration>()
          .map((d) => d.color)
          .whereType<Color>()
          .toList();
      for (final dark in const [
        BsTokens.bgDark,
        BsTokens.cardDark,
        BsTokens.inkDark,
        BsTokens.mutedDark,
      ]) {
        expect(decos, isNot(contains(dark)), reason: 'dark token $dark leaked');
        // No Material surface uses a dark token either.
        final matColors = t
            .widgetList<Material>(find.byType(Material))
            .map((m) => m.color)
            .whereType<Color>();
        expect(matColors, isNot(contains(dark)), reason: 'dark Material $dark');
      }
      // The summary strip is a white cardLight Container; the customer cards are
      // white cardLight Material surfaces (4 seed customers) — assert both.
      expect(decos, contains(BsTokens.cardLight));
      final cardSurfaces = t
          .widgetList<Material>(find.byType(Material))
          .map((m) => m.color)
          .where((col) => col == BsTokens.cardLight)
          .length;
      expect(cardSurfaces, greaterThanOrEqualTo(4));
    });
  });

  group('🛠️ ניהול — the 5 management tools (M5, manager screen COMPLETE)', () {
    // Switch to the 🛠️ ניהול tab by tapping its toggle pill. `.first` selects the
    // toggle pill (built above the IndexedStack body).
    Future<void> openManageTab(WidgetTester t) async {
      await t.tap(find.text('ניהול').first);
      await settle(t);
    }

    // Expand one accordion section by tapping its header title.
    // v2: the ניהול tab gained a 'בקשות חופשה' section above the tools, so a
    // header can sit below the fold — scroll it into view before tapping.
    Future<void> openSection(WidgetTester t, String title) async {
      await t.scrollUntilVisible(find.text(title), 200);
      await t.tap(find.text(title));
      await settle(t);
    }

    testWidgets('the tab shows the intro + all 5 management tool headers',
        (t) async {
      final c = await pumpScreen(t);
      await openManageTab(t);
      expect(c.read(managerTabProvider), 3);

      // The verbatim intro banner.
      expect(
        find.text('🛠️ שליטה מלאה על אפליקציית הקבלן — כל שינוי מתעדכן מיידית.'),
        findsOneWidget,
      );
      // The 5 tool section titles (verbatim legacy `mmSection` titles).
      for (final title in const [
        'קטגוריות',
        'הגדרות אפליקציה',
        'עץ המוצרים',
        'מותגים ומחירים',
        'בדיקות רגרסיה',
      ]) {
        expect(find.text(title), findsOneWidget, reason: 'tool $title header');
      }
    });

    testWidgets('🗂️ קטגוריות shows the LIVE category list with real counts',
        (t) async {
      final c = await pumpScreen(t);
      await openManageTab(t);
      await openSection(t, 'קטגוריות');

      // The header names the live category count (the analytics map size).
      final cats = c.read(managerAnalyticsProvider).catalogCategories;
      expect(find.text('קטגוריות פעילות (${cats.length})'), findsOneWidget);

      // Every category renders with its REAL product count (the verbatim
      // `<count> מוצרים` row), sourced from the live analytics map — NOT a
      // hard-coded literal. (Counts are unique enough that we assert the count
      // string appears for each; the category name appears once.)
      for (final e in cats.entries) {
        expect(find.text(e.key), findsOneWidget, reason: 'category ${e.key}');
        expect(
          find.text('${e.value} מוצרים'),
          findsWidgets,
          reason: 'category ${e.key} count',
        );
      }
      // The verbatim hint.
      expect(
        find.text('שינוי שם קטגוריה מעדכן את כל המוצרים שבה.'),
        findsOneWidget,
      );
    });

    testWidgets('⚙️ הגדרות אפליקציה shows the verbatim config rows', (t) async {
      await pumpScreen(t);
      await openManageTab(t);
      await openSection(t, 'הגדרות אפליקציה');

      // The three legacy config rows — verbatim labels + values (EXPRESS_FEE=120,
      // creditLimit=50,000 grouped, VAT_RATE=18%).
      expect(find.text('תוספת משלוח אקספרס'), findsOneWidget);
      expect(find.text('₪120'), findsOneWidget);
      expect(find.text('מסגרת אשראי לקבלן'), findsOneWidget);
      expect(find.text('₪50,000'), findsOneWidget);
      expect(find.text('שיעור מע״מ'), findsOneWidget);
      expect(find.text('18%'), findsOneWidget);
      // The verbatim hint.
      expect(
        find.text(
          'המע״מ קבוע לפי חוק (18%). תוספת האקספרס והאשראי נראים מיד בעגלת הקבלן.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('🌳 עץ המוצרים shows the inline catalog-tree summary', (t) async {
      final c = await pumpScreen(t);
      await openManageTab(t);
      await openSection(t, 'עץ המוצרים');

      final cats = c.read(managerAnalyticsProvider).catalogCategories;
      final total = cats.values.fold<int>(0, (s, n) => s + n);
      // The verbatim section purpose + the live tree size (products/categories).
      expect(
        find.text(
          'עריכת האביזרים המשלימים של כל מוצר — בחירת מוצר חושפת את עץ האביזרים שלו.',
        ),
        findsOneWidget,
      );
      expect(find.text('מוצרים בעץ'), findsOneWidget);
      expect(find.text('$total'), findsWidgets);
      expect(find.text('קטגוריות'), findsWidgets);
    });

    testWidgets('🏷️ מותגים ומחירים lists the brands from kBrands', (t) async {
      await pumpScreen(t);
      await openManageTab(t);
      await openSection(t, 'מותגים ומחירים');

      // The header names the brand count, and every brand name renders.
      expect(find.text('מותגים (${kBrands.length})'), findsOneWidget);
      for (final b in kBrands) {
        expect(find.text(b.name), findsOneWidget, reason: 'brand ${b.name}');
      }
    });

    testWidgets('🔬 בדיקות רגרסיה routes to RegressionPanelScreen', (t) async {
      await pumpScreen(t);
      await openManageTab(t);
      await openSection(t, 'בדיקות רגרסיה');

      expect(find.byType(RegressionPanelScreen), findsNothing);
      // Tap the action button → it pushes the existing RegressionPanelScreen.
      // (v2: the expanded section can open below the fold — scroll until the
      // button is FULLY visible; scrollUntilVisible alone can stop with its
      // center still past the viewport edge.)
      await t.scrollUntilVisible(find.text('🔬 פתח מרכז בדיקות רגרסיה'), 200);
      await t.ensureVisible(find.text('🔬 פתח מרכז בדיקות רגרסיה'));
      await t.pumpAndSettle();
      await t.tap(find.text('🔬 פתח מרכז בדיקות רגרסיה'));
      await settle(t);
      expect(find.byType(RegressionPanelScreen), findsOneWidget);
    });

    testWidgets('the manage tab is LIGHT — white cards on bgLight, NO dark tokens',
        (t) async {
      await pumpScreen(t);
      await openManageTab(t);

      final scaffold = t.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, BsTokens.bgLight);

      final decos = t
          .widgetList<Container>(find.byType(Container))
          .map((w) => w.decoration)
          .whereType<BoxDecoration>()
          .map((d) => d.color)
          .whereType<Color>()
          .toList();
      for (final dark in const [
        BsTokens.bgDark,
        BsTokens.cardDark,
        BsTokens.inkDark,
        BsTokens.mutedDark,
      ]) {
        expect(decos, isNot(contains(dark)), reason: 'dark token $dark leaked');
        final matColors = t
            .widgetList<Material>(find.byType(Material))
            .map((m) => m.color)
            .whereType<Color>();
        expect(matColors, isNot(contains(dark)), reason: 'dark Material $dark');
      }
      // The 5 section cards are white cardLight Containers.
      expect(
        decos.where((col) => col == BsTokens.cardLight).length,
        greaterThanOrEqualTo(5),
      );
    });
  });

  group('manager entry — role picker opens the dashboard (M1 wiring)', () {
    testWidgets('tapping "מנהל המערכת" in the "מי אתה?" picker pushes '
        'ManagerDashboardScreen', (t) async {
      SharedPreferences.setMockInitialValues({
      // #65 gate: seed a board session so the board (not the gate) renders.
      'bs.board-auth.v1':
          '{"role":"manager","username":"admin","displayName":"מנהל המערכת","demo":false}',
    });
      await t.binding.setSurfaceSize(const Size(440, 950));
      addTearDown(() => t.binding.setSurfaceSize(null));
      await t.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            locale: Locale('he'),
            home: HomeShell(),
          ),
        ),
      );
      await settle(t);

      // Open the "מי אתה?" persona picker from the BuildSmart logo (app-bar).
      await t.tap(find.text('BuildSmart'));
      await settle(t);
      expect(find.text('מי אתה?'), findsOneWidget);

      // Tap the manager persona row.
      await t.tap(find.text('מנהל המערכת'));
      await settle(t);

      // The dashboard SHELL is now on screen (NOT the BS-dial drill).
      expect(find.byType(ManagerDashboardScreen), findsOneWidget);
      expect(find.text('מרכז השליטה'), findsOneWidget);
    });

    testWidgets('showRolePicker → manager row pushes the dashboard directly',
        (t) async {
      SharedPreferences.setMockInitialValues({
      // #65 gate: seed a board session so the board (not the gate) renders.
      'bs.board-auth.v1':
          '{"role":"manager","username":"admin","displayName":"מנהל המערכת","demo":false}',
    });
      await t.binding.setSurfaceSize(const Size(440, 950));
      addTearDown(() => t.binding.setSurfaceSize(null));
      await t.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('he'),
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    // Drive the real role picker from role_picker_sheet.dart.
                    onPressed: () => showRolePicker(context),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await settle(t);

      await t.tap(find.text('open'));
      await settle(t);
      expect(find.text('מי אתה?'), findsOneWidget);

      await t.tap(find.text('מנהל המערכת'));
      await settle(t);

      // Manager routes to the dashboard SHELL (push), not the BS-dial drill.
      expect(find.byType(ManagerDashboardScreen), findsOneWidget);
    });
  });
}

/// Thousands-grouped integer — mirrors the screen's private `_grouped` (the
/// legacy `toLocaleString()` for ₪ sums) so the M4 credit-line assertions can
/// build the exact expected string.
String _grp(int n) {
  final s = n.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return n < 0 ? '-$buf' : buf.toString();
}
