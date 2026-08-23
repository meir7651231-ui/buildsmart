// Widget coverage of PHASE-0 HR relocation (owner governance ruling #84) on the
// 🛠️ ניהול tab of `ManagerDashboardScreen`. The runtime `kHrRelocationFlag`
// (default OFF) swaps the 👷 אישורי עובדים section between two shapes WITHOUT a
// rebuild:
//   • OFF (default) — the LIVE action queue: header sub-text
//     'משימות שעובדים שלחו לאישור', body has approve/reject.
//   • ON  — OVERSIGHT-ONLY: header sub-text 'מנוהל בלוח-הקבלן', the (expanded)
//     body is a read-only count keyed `Key('hr-oversight-approvals')`, no
//     approve/reject. The section title 'אישורי עובדים' + badge are unchanged.
// The sub-text lives in the ALWAYS-visible section header, so it is a purely
// flag-driven, seed-independent signal (no expand needed). Reuses the
// `manager_dashboard_screen_test.dart` harness (settle + pumpScreen) verbatim,
// and its `openManageTab` idiom to bring the offstage IndexedStack tab (index 3)
// onstage before asserting.

import 'package:buildsmart/screens/manager_dashboard_screen.dart';
import 'package:buildsmart/state/feature_flags.dart';
import 'package:buildsmart/state/manager_dashboard_state.dart';
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

  // Bring the 🛠️ ניהול tab (index 3) onstage by tapping its toggle pill.
  // `.first` selects the toggle pill (built above the IndexedStack body) even
  // after the tab's own body mounts. Mirrors the existing manager test.
  Future<void> openManageTab(WidgetTester t) async {
    await t.tap(find.text('ניהול').first);
    await settle(t);
  }

  group('manager HR relocation', () {
    test('kHrRelocationFlag is kHrRelocation', () {
      expect(kHrRelocationFlag, 'kHrRelocation');
    });

    testWidgets('OFF (default) — the 👷 אישורי עובדים section is the LIVE action '
        'queue (sub-text "משימות שעובדים שלחו לאישור", no oversight sub-text)',
        (t) async {
      final c = await pumpScreen(t);
      await openManageTab(t);
      expect(c.read(managerTabProvider), 3);
      // Default build: the flag is absent (not forced-on) → live section.
      expect(c.read(featureFlagsProvider).contains(kHrRelocationFlag), isFalse);

      // Flag-driven header signals (the section is item 0 of the ניהול list, so
      // its always-visible header is onstage once the tab is active).
      expect(find.text('מנוהל בלוח-הקבלן'), findsNothing);
      expect(find.text('משימות שעובדים שלחו לאישור'), findsOneWidget);
      // Title is unchanged across both states.
      expect(find.text('אישורי עובדים'), findsOneWidget);
    });

    testWidgets('ON — enabling kHrRelocationFlag makes the section '
        'OVERSIGHT-ONLY (sub-text "מנוהל בלוח-הקבלן"; expanded body keyed '
        'hr-oversight-approvals; the live-queue sub-text is gone)', (t) async {
      final c = await pumpScreen(t);
      await openManageTab(t);
      expect(c.read(managerTabProvider), 3);

      // Stage the flag ON at runtime on the SAME container the board watches —
      // exactly the production `ref.read(...notifier).enable(...)` path. Use the
      // harness's frame-pump `settle` (the file's chosen idiom) to flush the
      // rebuild rather than pumpAndSettle.
      c.read(featureFlagsProvider.notifier).enable(kHrRelocationFlag);
      await settle(t);
      expect(c.read(featureFlagsProvider).contains(kHrRelocationFlag), isTrue);

      // PRIMARY, seed-independent signal — the always-visible header sub-text
      // swaps; the live-queue sub-text disappears.
      expect(find.text('מנוהל בלוח-הקבלן'), findsOneWidget);
      expect(find.text('משימות שעובדים שלחו לאישור'), findsNothing);
      // Title unchanged.
      expect(find.text('אישורי עובדים'), findsOneWidget);

      // The oversight body carries `Key('hr-oversight-approvals')` and lives
      // inside the collapsed section (`if (open)`), so expand the section by
      // tapping its title (item 0 — always visible, no scroll) and assert the
      // read-only body mounted.
      await t.tap(find.text('אישורי עובדים'));
      await settle(t);
      expect(find.byKey(const Key('hr-oversight-approvals')), findsOneWidget);
    });
  });
}
