import 'package:buildsmart/screens/worker_task_board_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🗂️ WORKER TASK BOARD (#114) — the status-GROUPED hierarchical board of the
/// logged worker's tasks. Guards the #66 gate seed (a worker session renders
/// the board, not the registration gate), that the status group headers render,
/// and that a real seed task title appears (the deepest tier is the existing
/// #71 detail sheet — not re-tested here, it has its own coverage).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> settle(WidgetTester t, [int frames = 6]) async {
    for (var i = 0; i < frames; i++) {
      await t.pump(const Duration(milliseconds: 120));
    }
  }

  testWidgets(
      'worker board renders status group headers + a real seed task title',
      (t) async {
    // #66 gate: seed a logged-in worker session (ran → רן, worker 0) so the
    // board renders instead of the registration gate.
    SharedPreferences.setMockInitialValues({
      'bs.board-auth.v1':
          '{"role":"worker","username":"ran","displayName":"רן","demo":false}',
    });
    await t.binding.setSurfaceSize(const Size(440, 1000));
    addTearDown(() => t.binding.setSurfaceSize(null));

    await t.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: WorkerTaskBoardScreen()),
      ),
    );
    // Let the lazy boardAuthProvider _load() resolve, then rebuild gate→board.
    await settle(t);

    // The board AppBar title (proves the gate opened into the board).
    expect(find.text('🗂️ לוח משימות מלא'), findsOneWidget);

    // ≥2 status group headers — רן (worker 0) has an active task (group
    // 🔨 פעילות) and two queued tasks (group ⏳ בתור); the other groups still
    // render their headers too. Assert the two that carry his tasks.
    expect(find.text('🔨 פעילות'), findsOneWidget);
    expect(find.text('⏳ בתור'), findsOneWidget);

    // A real seed task title — task 1 (active) is verbatim from kPersonaTasks;
    // the active group starts expanded, so its row is on screen.
    expect(find.text('התקנת קו מים חם — חדר רחצה'), findsOneWidget);
  });
}
