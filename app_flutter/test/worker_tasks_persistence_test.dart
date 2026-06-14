// REGRESSION (audit H2) — a worker task's status must survive an app restart.
// Before the fix, worker tasks reset to their 'review' seed on relaunch while the
// orders they had advanced stayed advanced — so the manager could approve+advance
// the SAME install a second time across sessions (cross-session double-advance).
// The orders engine already persisted; the task engine did not. Now it persists
// an {id: {status, …}} overlay in lockstep, mirroring orders_engine. Wave T1
// collapsed the two task engines into one, so this now guards the unified
// `tasksProvider` (overlay key `bs.tasks-screen.v1`).

import 'dart:convert';

import 'package:buildsmart/state/orders_engine.dart';
import 'package:buildsmart/state/tasks_engine.dart';
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
    test('a persisted {id: {status, …}} overlay survives restart — load applies '
        'it onto the seed, per id', () async {
      // A prior session approved task 3 (unified overlay shape: bs.tasks-screen.v1
      // stores {id: {status, …}}, not the old {id: status}).
      SharedPreferences.setMockInitialValues({
        'bs.tasks-screen.v1': '{"3":{"status":"done"}}',
      });
      final c = ProviderContainer();
      addTearDown(c.dispose);
      c.read(tasksProvider.notifier); // construct → fires _load

      String statusOf(int id) =>
          c.read(tasksProvider).firstWhere((t) => t.id == id).status;

      await waitFor(() => statusOf(3) == 'done');
      expect(statusOf(3), 'done',
          reason: 'persisted approval must survive restart, not reset to seed');
      expect(statusOf(1), 'active', reason: 'overlay is per-id; others keep seed');
    });

    test('approving a task writes its status to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final c = ProviderContainer();
      addTearDown(c.dispose);

      c.read(tasksProvider.notifier).approve(3); // seeded 'review' → 'done'
      expect(
        c.read(tasksProvider).firstWhere((t) => t.id == 3).status,
        'done',
      );

      final prefs = await SharedPreferences.getInstance();
      // The unified overlay (bs.tasks-screen.v1) persists {id: {status, …}} — so
      // assert task 3's persisted status nested in its entry, not a flat
      // "3":"done".
      String? persistedStatus(int id) {
        final raw = prefs.getString('bs.tasks-screen.v1');
        if (raw == null || raw.isEmpty) return null;
        final m = jsonDecode(raw) as Map<String, dynamic>;
        final entry = m['$id'];
        return entry is Map ? entry['status'] as String? : null;
      }

      await waitFor(() => persistedStatus(3) == 'done');
      expect(persistedStatus(3), 'done');
    });

    test('REGRESSION — after a restart the manager cannot re-approve an already '
        'approved task (so the linked order is not advanced twice)', () async {
      SharedPreferences.setMockInitialValues({});

      // Session 1: approve linked task 3 → BS-1040 ready→pickup, task → done.
      final c1 = ProviderContainer();
      final tasks1 = c1.read(tasksProvider.notifier);
      String stage1() => c1
          .read(ordersEngineProvider)
          .firstWhere((o) => o.id == 'BS-1040')
          .stage;
      expect(stage1(), 'ready');
      tasks1.approve(3);
      expect(stage1(), 'pickup', reason: 'first approval advanced the order');

      final prefs = await SharedPreferences.getInstance();
      // Unified overlay shape (bs.tasks-screen.v1 → {id: {status, …}}): wait for
      // task 3's persisted status to land as 'done' before "relaunching".
      bool persisted3Done() {
        final raw = prefs.getString('bs.tasks-screen.v1');
        if (raw == null || raw.isEmpty) return false;
        final entry = (jsonDecode(raw) as Map<String, dynamic>)['3'];
        return entry is Map && entry['status'] == 'done';
      }

      await waitFor(persisted3Done);
      c1.dispose();

      // Session 2: a fresh container on the SAME prefs loads task 3 as 'done', so
      // approve() is a no-op (status != 'review') — no second advance.
      final c2 = ProviderContainer();
      addTearDown(c2.dispose);
      final tasks2 = c2.read(tasksProvider.notifier);
      String statusOf2(int id) =>
          c2.read(tasksProvider).firstWhere((t) => t.id == id).status;
      await waitFor(() => statusOf2(3) == 'done');
      expect(statusOf2(3), 'done', reason: 'approval persisted across restart');

      tasks2.approve(3); // must be a no-op on an already-done task
      expect(statusOf2(3), 'done',
          reason: 'a done task cannot be re-approved → no cross-session double-advance');
    });
  });
}
