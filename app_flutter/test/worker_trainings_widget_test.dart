// #108 · WorkerSafetyScreen → הדרכות section is wired to the REAL training log
// ([workerTrainingsProvider], bs.worker-trainings.v1), not a static const list.
// With no persisted store the notifier auto-seeds 3 removable DEMO rows on its
// first lazy _load(); this test seeds a logged-in worker session, pumps the
// screen, lets the lazy loads settle, and asserts the seeded demo titles render
// AND a '➕ הוסף הדרכה' affordance exists (the add-sheet entry point).
import 'package:buildsmart/screens/worker_safety_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
      'WorkerSafetyScreen renders the REAL seeded trainings + an add affordance',
      (tester) async {
    // #65 gate: with no board session the screen builds ONLY the registration
    // gate — seed a logged-in worker session (ran) so the real safety bag
    // renders. No bs.worker-trainings.v1 key → the notifier seeds the demo rows.
    SharedPreferences.setMockInitialValues({
      'bs.board-auth.v1':
          '{"role":"worker","username":"ran","displayName":"רן","demo":false}',
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('he'),
          home: WorkerSafetyScreen(),
        ),
      ),
    );
    await tester.pump();
    // Let the lazy boardAuthProvider _load() (gate→board) resolve and rebuild.
    await tester.pump(const Duration(milliseconds: 100));
    // The board build is the FIRST read of workerTrainingsProvider, whose own
    // async _load() (empty store → demo seed) then resolves on a second tick;
    // settle covers that load + the resulting rebuild deterministically.
    await tester.pumpAndSettle();

    // The board actually rendered (not the WelcomeScreen gate): the section
    // header is present.
    expect(find.text('🎓 הדרכות שעברתי (3)'), findsOneWidget,
        reason: 'the real trainings card rendered with the 3 seeded rows');

    // The DEMO-SEED training titles (from worker_trainings.dart demoSeed) are
    // shown — proving the card reads the store, not the old static const list.
    expect(find.text('הדרכת בטיחות כללית באתר'), findsOneWidget);
    expect(find.text('עבודה בגובה'), findsOneWidget);
    expect(find.text('ציוד מגן אישי'), findsOneWidget);

    // The honest demo hint stays while the seeded rows are present.
    expect(
      find.text('נתוני דמו — רישום הדרכות אמיתי יחובר עם חיבור השרת.'),
      findsOneWidget,
    );

    // The add-training affordance exists (opens the '➕ הוסף הדרכה' sheet).
    expect(find.text('➕ הוסף הדרכה'), findsOneWidget,
        reason: 'the add-training entry point is present (#108)');
  });
}
