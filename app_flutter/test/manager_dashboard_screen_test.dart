// M1 — widget coverage of the 👔 manager dashboard SHELL (`ManagerDashboardScreen`).
// Asserts: (1) the screen BUILDS as a LIGHT full-role-app frame (bgLight scaffold +
// white AppBar + the "מרכז השליטה" / "מנהל המערכת" titles + a "חי" pill), (2) the
// 4-tab segmented toggle SWITCHES the IndexedStack body (tab placeholders are
// "בקרוב" this wave), and (3) the manager entry in the role picker ("מי אתה?" →
// מנהל המערכת) OPENS this screen via Navigator.push — instead of the old BS-dial
// drill. Tabs are PLACEHOLDERS (M2–M5 fill them).

import 'package:buildsmart/screens/home_shell.dart';
import 'package:buildsmart/screens/manager_dashboard_screen.dart';
import 'package:buildsmart/screens/role_picker_sheet.dart';
import 'package:buildsmart/state/manager_dashboard_state.dart';
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

    testWidgets('placeholder bodies show the "בקרוב" note (M2–M5 not built)',
        (t) async {
      await pumpScreen(t);
      // The active tab's "בקרוב" is onstage; the IndexedStack keeps the other
      // three mounted offstage — so all four placeholders exist (skipOffstage:
      // false counts the offstage ones too).
      expect(find.text('בקרוב'), findsOneWidget);
      expect(
        find.text('בקרוב', skipOffstage: false),
        findsNWidgets(4),
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
