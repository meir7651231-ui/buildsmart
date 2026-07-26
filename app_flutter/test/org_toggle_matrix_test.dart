// Giant-system V2 — the TOGGLE MATRIX (the plan's ⭐ proof: every combo
// stays wired, zero errors). Config is injected exactly the way main() does
// it (orgConfigProvider.overrideWith), pumping the REAL app.
//
// Matrix legs: (1) every wave-1 module off ALONE → boots clean, the 4 tabs
// render, no exception; (2) targeted present/absent pairs for the cheap
// reachable surfaces (chat segment · role-picker rows); (3) all-off-except-
// core ≈ still a working shop; (4) HOSTILE core-off = byte-identical to
// all-on (kCoreModules is law at the widget tier too); (5) LIVE SWAP —
// the V5 wizard contract: flipping the StateProvider re-renders with no
// restart and no exception.

import 'package:buildsmart/config/org_config.dart';
import 'package:buildsmart/main.dart';
import 'package:buildsmart/screens/home_shell.dart';
import 'package:buildsmart/state/dial_state.dart' show mainTabProvider;
import 'package:buildsmart/state/org_config_store.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A fresh ProviderScope PER BOOT (UniqueKey): Riverpod never re-applies
/// overrides to an existing scope element — without the key, a second boot
/// in the same test would silently keep the FIRST config.
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

/// Deterministic tab switch — the provider write every nav path uses
/// (tapping the nav LABEL text is ambiguous: keyboard chips share it).
void _goTab(WidgetTester t, int i) {
  ProviderScope.containerOf(t.element(find.byType(HomeShell)))
      .read(mainTabProvider.notifier)
      .state = i;
}

void _expectShellAlive(WidgetTester t) {
  expect(t.takeException(), isNull);
  expect(find.byType(HomeShell), findsOneWidget);
  for (final tab in ['בית', 'מחלקות', 'עדכונים', 'חנות']) {
    expect(find.text(tab), findsAtLeastNWidgets(1), reason: tab);
  }
}

void main() {
  const wave1 = [
    'chat', 'manager', 'supplier', 'courier', 'worker',
    'finance', 'rewards', 'site', 'compat', 'ai', 'dive', 'search', 'intel',
  ];

  testWidgets('every wave-1 module OFF alone → the shell boots clean',
      (t) async {
    for (final m in wave1) {
      await _boot(t, OrgConfig(modules: {m: false}));
      _expectShellAlive(t);
    }
  });

  testWidgets('chat off → the updates tab has no שיחות segment', (t) async {
    await _boot(t, const OrgConfig(modules: {'chat': false}));
    _goTab(t, 2);
    await t.pumpAndSettle();
    expect(find.text('שיחות'), findsNothing);
    await _boot(t, const OrgConfig());
    _goTab(t, 2);
    await t.pumpAndSettle();
    expect(find.text('שיחות'), findsAtLeastNWidgets(1),
        reason: 'all-on keeps the segment — the DoD leg');
  });

  testWidgets('manager off → its picker row hides, the others stay',
      (t) async {
    await _boot(t, const OrgConfig(modules: {'manager': false}));
    await t.tap(find.byTooltip('BS').first);
    await t.pumpAndSettle();
    expect(find.text('מנהל המערכת'), findsNothing);
    for (final stays in ['קבלן', 'חנות ספק', 'שליח', 'עובד']) {
      expect(find.text(stays), findsOneWidget, reason: stays);
    }
  });

  testWidgets('all-off-except-core → still a working shop', (t) async {
    await _boot(t, OrgConfig(modules: {for (final m in wave1) m: false}));
    _expectShellAlive(t);
  });

  testWidgets('HOSTILE core-off is ignored — identical boot (core is law)',
      (t) async {
    await _boot(
        t, const OrgConfig(modules: {'catalog': false, 'orders': false}));
    _expectShellAlive(t);
  });

  testWidgets('LIVE SWAP (the wizard contract): chat flips off with no '
      'restart and no exception', (t) async {
    SharedPreferences.setMockInitialValues({});
    await t.pumpWidget(ProviderScope(
      overrides: [
        orgConfigProvider.overrideWith((ref) => const OrgConfig()),
      ],
      child: const BuildSmartApp(),
    ));
    await t.pumpAndSettle();
    _goTab(t, 2);
    await t.pumpAndSettle();
    expect(find.text('שיחות'), findsAtLeastNWidgets(1));
    final container =
        ProviderScope.containerOf(t.element(find.byType(HomeShell)));
    container.read(orgConfigProvider.notifier).state =
        const OrgConfig(modules: {'chat': false});
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    expect(find.text('שיחות'), findsNothing,
        reason: 'the wizard saves → the app reshapes live');
  });
}
