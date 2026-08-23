// Giant-system V3 wave-1 — ORG TERMS (מילון-המונחים), proven on the REAL app:
// (1) no terms ⇒ labels byte-identical (the DoD default); (2) terms rebrand
// the nav tabs, a runtime brand site, and ANY CfgText id (site-level);
// (3) a published Studio override STILL WINS over the term — the plan's
// coexistence DoD ("Studio עדיין דורס, מנצח"); (4) LIVE SWAP — the V5 wizard
// flips the provider and every termed label re-renders, no restart.
//
// Trap notes carried from org_toggle_matrix_test: a fresh ProviderScope needs
// a UniqueKey PER BOOT (Riverpod never re-applies overrides to an existing
// scope element), and tab labels also exist as keyboard chips — nav asserts
// therefore match on BottomNavCell, not bare text.

import 'package:buildsmart/config/org_config.dart';
import 'package:buildsmart/main.dart';
import 'package:buildsmart/screens/home_shell.dart';
import 'package:buildsmart/screens/profile_screen.dart';
import 'package:buildsmart/state/auth_state.dart' show authGatewayProvider;
import 'package:buildsmart/state/org_config_store.dart';
import 'package:buildsmart/state/studio/config_store.dart'
    show SetText, configStoreProvider;
import 'package:buildsmart/widgets/help_target.dart' show BottomNavCell;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app(OrgConfig cfg) => ProviderScope(
      key: UniqueKey(),
      overrides: [orgConfigProvider.overrideWith((ref) => cfg)],
      child: const BuildSmartApp(),
    );

Future<void> _boot(WidgetTester t, OrgConfig cfg) async {
  SharedPreferences.setMockInitialValues({});
  await t.pumpWidget(_app(cfg));
  await t.pumpAndSettle();
}

ProviderContainer _container(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(HomeShell)));

/// A nav-bar-scoped label finder — bare `find.text` is ambiguous (keyboard
/// chips and section titles share the tab vocabulary).
Finder _navLabel(String label) => find.widgetWithText(BottomNavCell, label);

/// ProfileScreen direct-pump (the login_sheet_test pattern): auth gateway
/// pinned to null (Firebase-free), tall surface for the long list.
Future<void> _pumpProfile(WidgetTester t, OrgConfig cfg) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  await t.binding.setSurfaceSize(const Size(440, 1700));
  addTearDown(() => t.binding.setSurfaceSize(null));
  await t.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [
        authGatewayProvider.overrideWithValue(null),
        orgConfigProvider.overrideWith((ref) => cfg),
      ],
      child: const MaterialApp(locale: Locale('he'), home: ProfileScreen()),
    ),
  );
  await t.pumpAndSettle();
}

void main() {
  testWidgets('DoD default — no terms ⇒ the wordmark and all 4 tab labels '
      'are byte-identical', (t) async {
    await _boot(t, const OrgConfig());
    expect(find.text('BuildSmart'), findsOneWidget);
    for (final tab in ['בית', 'מחלקות', 'עדכונים', 'חנות']) {
      expect(_navLabel(tab), findsOneWidget, reason: tab);
    }
  });

  testWidgets('nav.* terms rebrand the bottom tabs', (t) async {
    await _boot(t,
        const OrgConfig(terms: {'nav.catalog': 'קטלוג', 'nav.store': 'שוק'}));
    expect(t.takeException(), isNull);
    expect(_navLabel('קטלוג'), findsOneWidget);
    expect(_navLabel('מחלקות'), findsNothing);
    expect(_navLabel('שוק'), findsOneWidget);
    expect(_navLabel('חנות'), findsNothing);
    expect(_navLabel('בית'), findsOneWidget, reason: 'untermed tab untouched');
  });

  testWidgets('site-level term — ANY CfgText id rebrands by its own key '
      '(the wordmark)', (t) async {
    await _boot(
        t, const OrgConfig(terms: {'home.topbar.brand': 'אלמוג בניין'}));
    expect(find.text('אלמוג בניין'), findsOneWidget);
    expect(find.text('BuildSmart'), findsNothing);
  });

  testWidgets('brand.club term reaches the profile club row (and default '
      'stays verbatim)', (t) async {
    await _pumpProfile(t, const OrgConfig());
    expect(find.text('🎮 מועדון BuildSmart'), findsOneWidget);
    await _pumpProfile(
        t, const OrgConfig(terms: {'brand.club': 'מועדון הזהב'}));
    expect(find.text('🎮 מועדון הזהב'), findsOneWidget);
    expect(find.text('🎮 מועדון BuildSmart'), findsNothing);
  });

  testWidgets('STUDIO WINS — a published override beats the org term '
      '(coexistence DoD)', (t) async {
    await _boot(
        t, const OrgConfig(terms: {'home.topbar.brand': 'מונח-ארגוני'}));
    expect(find.text('מונח-ארגוני'), findsOneWidget,
        reason: 'pre-publish, the term is in force');
    _container(t).read(configStoreProvider.notifier)
      ..applyOps(const [SetText('home.topbar.brand', 'סטודיו-מנצח')])
      ..publish(nowMs: 1);
    await t.pumpAndSettle();
    expect(find.text('סטודיו-מנצח'), findsOneWidget);
    expect(find.text('מונח-ארגוני'), findsNothing,
        reason: 'Studio dominates — the term only fills un-overridden labels');
  });

  testWidgets('LIVE SWAP (the wizard contract) — terms re-render with no '
      'restart and no exception', (t) async {
    await _boot(t, const OrgConfig());
    expect(_navLabel('מחלקות'), findsOneWidget);
    _container(t).read(orgConfigProvider.notifier).state =
        const OrgConfig(terms: {'nav.catalog': 'קטלוג'});
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    expect(_navLabel('קטלוג'), findsOneWidget);
    expect(_navLabel('מחלקות'), findsNothing,
        reason: 'the wizard saves → the label reshapes live');
  });
}
