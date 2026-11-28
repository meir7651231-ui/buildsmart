// 🔧 defects_sheet — the role split must match the contractor's real surface.
//
// The contractor's main app (site hub → 🔧 ליקויים) has NO board session, so
// the old `isContractor = session?.role == manager` sent the contractor down
// the WORKER branch: "דווח ליקוי — יישלח לקבלן", an always-empty list (no
// worker index), and a save button that silently did nothing. Only a WORKER
// session may take the worker branch (mirrors tasks_gantt_sheet).
import 'package:buildsmart/data/board_accounts_local.dart';
import 'package:buildsmart/screens/defects_sheet.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _open(
  WidgetTester tester, {
  BoardRole? demoRole,
  String? contractorDefect,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.reset);
  final c = ProviderContainer();
  addTearDown(c.dispose);
  // Let the lazy board-auth _load() settle before seeding the session.
  c.read(boardAuthProvider);
  await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  if (demoRole != null) c.read(boardAuthProvider.notifier).enterDemo(demoRole);
  if (contractorDefect != null) {
    c.read(tasksProvider.notifier).createTask(
          name: contractorDefect,
          kind: 'defect',
          employerId: kDemoContractorId,
        );
  }
  await tester.pumpWidget(UncontrolledProviderScope(
    container: c,
    child: MaterialApp(
      home: Builder(
        builder: (ctx) => Scaffold(
          body: TextButton(
            onPressed: () => showDefectsSheet(ctx),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return c;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  testWidgets('no board session (contractor main app) → contractor form',
      (tester) async {
    await _open(tester);
    expect(find.text('➕ פתח ליקוי'), findsOneWidget);
    expect(find.text('➕ דווח ליקוי'), findsNothing);
  });

  testWidgets('no board session → the contractor sees their own defects',
      (tester) async {
    await _open(tester, contractorDefect: 'סדק בקיר הסלון');
    expect(find.textContaining('סדק בקיר הסלון'), findsOneWidget);
  });

  testWidgets('a lingering courier demo session is still not a worker',
      (tester) async {
    await _open(tester,
        demoRole: BoardRole.courier, contractorDefect: 'רטיבות בתקרה');
    expect(find.text('➕ פתח ליקוי'), findsOneWidget);
    expect(find.text('➕ דווח ליקוי'), findsNothing);
    expect(find.textContaining('רטיבות בתקרה'), findsOneWidget);
  });

  testWidgets('a worker session keeps the worker report form', (tester) async {
    await _open(tester, demoRole: BoardRole.worker);
    expect(find.text('➕ דווח ליקוי'), findsOneWidget);
    expect(find.text('➕ פתח ליקוי'), findsNothing);
  });
}
