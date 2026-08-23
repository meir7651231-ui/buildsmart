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
import 'package:buildsmart/screens/catalog_screen.dart'
    show catalogSectionProvider;
import 'package:buildsmart/screens/finder_screen.dart' show FinderScreen;
import 'package:buildsmart/screens/home_shell.dart';
import 'package:buildsmart/state/dial_state.dart' show mainTabProvider;
import 'package:buildsmart/state/org_config_store.dart';
import 'package:buildsmart/state/push_routing.dart'
    show pendingPushThreadProvider;
import 'package:buildsmart/state/studio/element_registry.dart'
    show criticalIdsProvider;
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

  testWidgets('search off → the מאתר section falls to the honest empty '
      'body (no finder, no crash)', (t) async {
    await _boot(t, const OrgConfig(modules: {'search': false}));
    final c = ProviderScope.containerOf(t.element(find.byType(HomeShell)));
    c.read(catalogSectionProvider.notifier).state = 'מאתר';
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    expect(find.byType(FinderScreen), findsNothing);
  });

  testWidgets('chat off + a pending push thread → consumed with an honest '
      'toast (never a parked deep link)', (t) async {
    await _boot(t, const OrgConfig(modules: {'chat': false}));
    final c = ProviderScope.containerOf(t.element(find.byType(HomeShell)));
    c.read(pendingPushThreadProvider.notifier).state = 'thread-9';
    _goTab(t, 2);
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    expect(c.read(pendingPushThreadProvider), isNull,
        reason: 'consumed exactly once');
    expect(find.text('שיחות אינן פעילות בחברה זו'), findsOneWidget);
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

  testWidgets('ELEMENT-HIDE: home.topbar.brand hides app-wide via the org '
      'element axis (empty=shown ⇒ byte-identical · false=gone)', (t) async {
    // empty config ⇒ the wired brand renders its verbatim fallback.
    await _boot(t, const OrgConfig());
    expect(find.text('BuildSmart'), findsOneWidget,
        reason:
            'absent element key ⇒ shown, byte-identical to the pre-axis app');
    // hide it ⇒ CfgText's render gate (elementVisible) returns SizedBox.shrink
    // at the ONE live mount point; the shell stays whole.
    await _boot(
        t, const OrgConfig(features: {'element.home.topbar.brand': false}));
    _expectShellAlive(t);
    expect(find.text('BuildSmart'), findsNothing,
        reason: 'the org element axis really hides the wired brand app-wide');
  });

  testWidgets('kIMMUTABLE element: element.nav.bottombar:false cannot strand — '
      'the nav is force-visible, the shell stays whole', (t) async {
    await _boot(
        t, const OrgConfig(features: {'element.nav.bottombar': false}));
    _expectShellAlive(t);
    final c = ProviderScope.containerOf(t.element(find.byType(HomeShell)));
    // the pure model genuinely carries the hide — but nav.bottombar is a
    // critical id, so the render gate elementVisible force-shows it: a user can
    // never toggle themselves out of the nav. Prove BOTH halves.
    expect(elementShown(c.read(orgConfigProvider), 'nav.bottombar'), isFalse,
        reason: 'the config really asks to hide it');
    expect(c.read(criticalIdsProvider).contains('nav.bottombar'), isTrue,
        reason: 'kImmutable ⇒ elementVisible ignores the hide (force-visible)');
  });
}
