import 'package:buildsmart/data/persona_data.dart';
import 'package:buildsmart/screens/worker_app_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🦺 עובד role-app (T9, rebuilt in the app's own style — same shell, different
/// content). Guards the verbatim demo data + bucket filters (proto 06 §4.1/§4.2)
/// and that the screen renders task cards (not a "בבנייה" stub). R8.
void main() {
  group('worker demo data (verbatim, R8)', () {
    test('5 tasks + workers verbatim', () {
      expect(kPersonaTasks.length, 5);
      expect(kWorkers, ['רן (עובד)', 'עומר (עובד)']);
      expect(kPersonaTasks.first.name, 'התקנת קו מים חם — חדר רחצה');
    });

    test('bucket filters match the prototype (current/queue/submitted)', () {
      // רן (0): 1 active, 2+5 pending
      expect(tasksFor(0, {'active', 'rejected'}).map((t) => t.id), [1]);
      expect(tasksFor(0, {'pending'}).map((t) => t.id), [2, 5]);
      expect(tasksFor(0, {'review', 'done'}), isEmpty);
      // עומר (1): 3 review, 4 done
      expect(tasksFor(1, {'review', 'done'}).map((t) => t.id), [3, 4]);
      expect(tasksFor(1, {'active', 'rejected'}), isEmpty);
      // totals
      expect(tasksForWorker(0).length, 3);
      expect(tasksForWorker(1).length, 2);
    });

    test('workerShortName strips " (עובד)"', () {
      expect(workerShortName(0), 'רן');
      expect(workerShortName(1), 'עומר');
    });
  });

  testWidgets('worker app renders cards in the app style (no בבנייה)',
      (tester) async {
    // #65 gate: with no board session the screen shows ONLY the registration
    // gate — seed a logged-in worker session (ran) so the board renders.
    SharedPreferences.setMockInitialValues({
      'bs.board-auth.v1':
          '{"role":"worker","username":"ran","displayName":"רן","demo":false}',
    });
    // The worker screen now reads the shared workerTasksProvider, so it must be
    // pumped inside a ProviderScope (cross-persona wiring W3).
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: WorkerAppScreen())),
    );
    await tester.pump();
    // Let the lazy boardAuthProvider _load() resolve, then rebuild gate→board.
    await tester.pump(const Duration(milliseconds: 100));

    // App chrome + verbatim content (the רן/עומר toggle is gone — #66: the
    // logged worker sees only their own board).
    expect(find.text('🦺 עובד'), findsOneWidget);
    // #113 — the home is now a JOURNAL: the week-strip + day-attendance cards
    // lead, so the greeting/summary card sits below them in the lazy ListView.
    await tester.scrollUntilVisible(find.textContaining('שלום, רן'), 120);
    expect(find.textContaining('שלום, רן'), findsOneWidget);
    // v2: the 'היום שלי' strip sits above the buckets, pushing the queue
    // header below the fold of the lazy ListView — scroll to each section.
    await tester.scrollUntilVisible(find.text('🔨 המשימה הנוכחית שלך'), 200);
    expect(find.text('🔨 המשימה הנוכחית שלך'), findsOneWidget);
    // The title appears in the 'היום שלי' strip (today+next day-stages) AND
    // on the task card — at least one is enough.
    expect(find.text('התקנת קו מים חם — חדר רחצה'), findsWidgets);
    await tester.scrollUntilVisible(find.text('⏳ הבאות בתור (2)'), 200);
    expect(find.text('⏳ הבאות בתור (2)'), findsOneWidget);

    // Real task cards, not a stub.
    await tester.scrollUntilVisible(find.text('הרכבת מיכל הדחה סמוי'), 200);
    expect(find.text('הרכבת מיכל הדחה סמוי'), findsOneWidget);
    expect(find.textContaining('בבנייה'), findsNothing);
  });
}
