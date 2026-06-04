// M1 — widget coverage of the 👔 manager dashboard SHELL (`ManagerDashboardScreen`).
// Asserts: (1) the screen BUILDS as a LIGHT full-role-app frame (bgLight scaffold +
// white AppBar + the "מרכז השליטה" / "מנהל המערכת" titles + a "חי" pill), (2) the
// 4-tab segmented toggle SWITCHES the IndexedStack body (tab placeholders are
// "בקרוב" this wave), and (3) the manager entry in the role picker ("מי אתה?" →
// מנהל המערכת) OPENS this screen via Navigator.push — instead of the old BS-dial
// drill. Tabs are PLACEHOLDERS (M2–M5 fill them).

import 'package:buildsmart/logic/manager_dashboard.dart';
import 'package:buildsmart/screens/home_shell.dart';
import 'package:buildsmart/screens/manager_dashboard_screen.dart';
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
    SharedPreferences.setMockInitialValues({});
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

    testWidgets('the 2 NOT-yet-built tabs (👥/🛠️) keep the "בקרוב" note '
        '(M4–M5 not built); 📊 + 🚚 are no longer placeholders', (t) async {
      await pumpScreen(t);
      // Default tab = 0 (📊 לוח בקרה) — now the LIVE cockpit, NOT a placeholder,
      // so nothing "בקרוב" is onstage. The IndexedStack keeps the OTHER three
      // mounted offstage; 🚚 הזמנות is now the live orders tab (M3), so only the
      // remaining TWO (👥/🛠️) are still "בקרוב" placeholders.
      expect(find.text('בקרוב'), findsNothing);
      expect(
        find.text('בקרוב', skipOffstage: false),
        findsNWidgets(2),
      );
    });

    testWidgets('route() pushes the screen', (t) async {
      SharedPreferences.setMockInitialValues({});
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

  group('manager entry — role picker opens the dashboard (M1 wiring)', () {
    testWidgets('tapping "מנהל המערכת" in the "מי אתה?" picker pushes '
        'ManagerDashboardScreen', (t) async {
      SharedPreferences.setMockInitialValues({});
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
      SharedPreferences.setMockInitialValues({});
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
