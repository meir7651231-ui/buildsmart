// REGRESSION (audit H2) — a worker task's status must survive an app restart.
// Before the fix, worker tasks reset to their 'review' seed on relaunch while the
// orders they had advanced stayed advanced — so the manager could approve+advance
// the SAME install a second time across sessions (cross-session double-advance).
// The orders engine already persisted; the worker-tasks engine did not. Now it
// persists a compact {id: status} overlay in lockstep, mirroring orders_engine.

import 'package:buildsmart/state/orders_engine.dart';
import 'package:buildsmart/state/worker_tasks_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Poll until [cond] holds (lets the fire-and-forget _load/_persist settle), or
  // give up after ~1s so a real failure still fails the test rather than hangs.
  Future<void> waitFor(bool Function() cond) async {
    for (var i = 0; i < 200; i++) {
      if (cond()) return;
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
  }

  group('worker tasks persistence (audit H2)', () {
    test('a persisted {id: status} overlay survives restart — load applies it '
        'onto the seed, per id', () async {
      // A prior session approved task 3.
      SharedPreferences.setMockInitialValues({
        'bs.worker-tasks.v1': '{"3":"done"}',
      });
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(workerTasksProvider.notifier); // construct → fires _load

      String statusOf(int id) =>
          c.read(workerTasksProvider).firstWhere((t) => t.id == id).status;

      await waitFor(() => statusOf(3) == 'done');
      expect(statusOf(3), 'done',
          reason: 'persisted approval must survive restart, not reset to seed');
      expect(statusOf(1), 'active', reason: 'overlay is per-id; others keep seed');
    });

    test('approving a task writes its status to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);

      c.read(workerTasksProvider.notifier).approve(3); // seeded 'review' → 'done'
      expect(
        c.read(workerTasksProvider).firstWhere((t) => t.id == 3).status,
        'done',
      );

      final prefs = await SharedPreferences.getInstance();
      await waitFor(
          () => (prefs.getString('bs.worker-tasks.v1') ?? '').contains('"3":"done"'));
      expect(prefs.getString('bs.worker-tasks.v1'), contains('"3":"done"'));
    });

    test('REGRESSION — after a restart the manager cannot re-approve an already '
        'approved task (so the linked order is not advanced twice)', () async {
      SharedPreferences.setMockInitialValues({});

      // Session 1: approve linked task 3 → BS-1040 ready→pickup, task → done.
      final c1 = ProviderContainer();
      final tasks1 = c1.read(workerTasksProvider.notifier);
      String stage1() => c1
          .read(ordersEngineProvider)
          .firstWhere((o) => o.id == 'BS-1040')
          .stage;
      expect(stage1(), 'ready');
      tasks1.approve(3);
      expect(stage1(), 'pickup', reason: 'first approval advanced the order');

      final prefs = await SharedPreferences.getInstance();
      await waitFor(
          () => (prefs.getString('bs.worker-tasks.v1') ?? '').contains('"3":"done"'));
      c1.dispose();

      // Session 2: a fresh container on the SAME prefs loads task 3 as 'done', so
      // approve() is a no-op (status != 'review') — no second advance.
      final c2 = ProviderContainer();
      addTearDown(c2.dispose);
      final tasks2 = c2.read(workerTasksProvider.notifier);
      String statusOf2(int id) =>
          c2.read(workerTasksProvider).firstWhere((t) => t.id == id).status;
      await waitFor(() => statusOf2(3) == 'done');
      expect(statusOf2(3), 'done', reason: 'approval persisted across restart');

      tasks2.approve(3); // must be a no-op on an already-done task
      expect(statusOf2(3), 'done',
          reason: 'a done task cannot be re-approved → no cross-session double-advance');
    });
  });
}
