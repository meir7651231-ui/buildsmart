// #109 · דוחות-עובד — every summary section is now a LIVE drill-down, not a dead
// tap. This widget test pumps the reports tab for a seeded worker, taps the
// first-pass KPI box, and asserts a real drill-down sheet opens with the actual
// task behind the number (the done task we seeded) — proving the tap is wired to
// live data, not a no-op.
//
// Deterministic: the worker's tasks are seeded through the bs.tasks-screen.v1
// overlay (the engine's own persistence key) so the tab reads a known done task
// for worker 0 (רן); pumps are explicit-duration (the lazy providers' async
// _load resolves on a fixed tick), never a wall-clock wait.
import 'dart:convert';

import 'package:buildsmart/screens/worker_reports_tab.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpTab(WidgetTester tester) async {
  await tester.pumpWidget(
    const ProviderScope(
      child: MaterialApp(
        locale: Locale('he'),
        // The tab posts toasts via ScaffoldMessenger and opens modal sheets via
        // its own context under the Navigator — a Scaffold host covers both.
        home: Scaffold(body: WorkerReportsTab(worker: 0)),
      ),
    ),
  );
  await tester.pump(); // first frame
  // Let the lazy taskClock/rejectNote FutureProviders' async _load resolve and
  // rebuild the tab with the seeded values.
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  testWidgets(
      'tapping the first-pass KPI box opens a real drill-down sheet listing the '
      'seeded done task (not a dead tap)', (tester) async {
    // Seed worker 0 (רן): task 1 → done WITH a completedAt stamp, so the
    // first-pass drill-down has real content to list (and the streak/week
    // sections have a real day too). The overlay is the engine's own
    // bs.tasks-screen.v1 key, applied onto the verbatim seed.
    final stamp = DateTime.now().toIso8601String();
    SharedPreferences.setMockInitialValues({
      kTasksScreenKey: jsonEncode({
        '1': {
          'status': 'done',
          'photo': 'demo',
          'note': 'בוצע ונבדק',
          'startedAt': stamp,
          'completedAt': stamp,
          'doneSteps': <int>[],
        },
      }),
    });

    await _pumpTab(tester);

    // Pre-condition: the tab actually rendered (the KPI label is present).
    expect(find.text('אישור-ראשון 🎯'), findsOneWidget,
        reason: 'the reports tab rendered with the KPI row');

    // Tap the first-pass KPI box (the box wraps its label in a button).
    await tester.tap(find.text('אישור-ראשון 🎯'));
    await tester.pumpAndSettle();

    // A REAL drill-down sheet opened (its title) with the seeded done task
    // listed under it — proving the tap reached live data, not a dead handler.
    expect(find.text('🎯 אישור-ראשון — פירוט'), findsOneWidget,
        reason: 'the first-pass drill-down sheet opened');
    expect(find.text('✅ אושרו ללא דחייה (1/1)'), findsOneWidget,
        reason: 'the sheet shows the live done-vs-submitted breakdown');
    expect(find.text('התקנת קו מים חם — חדר רחצה'), findsWidgets,
        reason: 'the seeded done task (id 1) is listed as real content');

    // The sheet has an explicit ≥48dp close (sheet rule) — tapping it dismisses.
    await tester.tap(find.bySemanticsLabel('סגור').first);
    await tester.pumpAndSettle();
    expect(find.text('🎯 אישור-ראשון — פירוט'), findsNothing,
        reason: 'the close button dismisses the drill-down');
  });

  testWidgets(
      'tapping the BuildCoins KPI box opens the rewards breakdown with the '
      'honest device-shared framing', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await _pumpTab(tester);

    expect(find.text('BuildCoins (מועדון משותף) 🪙'), findsOneWidget);
    await tester.tap(find.text('BuildCoins (מועדון משותף) 🪙'));
    await tester.pumpAndSettle();

    // The coins drill-down opened and keeps the honest 'מועדון משותף' framing
    // (NOT a per-worker ledger) — a real provider read, not a dead tap.
    expect(find.text('🪙 BuildCoins — מועדון משותף'), findsOneWidget);
    // Assert a substring UNIQUE to the drill-down disclaimer: the reports tab's
    // own KPI explanation also mentions the shared club ('...המשותף לכל
    // התפקידים...'), so a generic substring matches twice. 'מאזן המטבעות הוא'
    // opens only the drill-down's disclaimer (worker_report_drilldowns.dart).
    expect(find.textContaining('מאזן המטבעות הוא'), findsOneWidget,
        reason: 'the device-shared framing is preserved in the drill-down');
  });
}
