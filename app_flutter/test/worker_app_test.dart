import 'package:buildsmart/data/persona_data.dart';
import 'package:buildsmart/screens/worker_app_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
    await tester.pumpWidget(const MaterialApp(home: WorkerAppScreen()));
    await tester.pump();

    // App chrome + verbatim content.
    expect(find.text('🦺 עובד'), findsOneWidget);
    expect(find.text('רן (עובד)'), findsWidgets);
    expect(find.textContaining('שלום, רן'), findsOneWidget);
    expect(find.text('🔨 המשימה הנוכחית שלך'), findsOneWidget);
    expect(find.text('⏳ הבאות בתור (2)'), findsOneWidget);

    // Real task cards, not a stub.
    expect(find.text('התקנת קו מים חם — חדר רחצה'), findsOneWidget);
    expect(find.text('הרכבת מיכל הדחה סמוי'), findsOneWidget);
    expect(find.textContaining('בבנייה'), findsNothing);
  });
}
