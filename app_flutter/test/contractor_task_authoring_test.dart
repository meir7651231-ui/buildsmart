// CROSS-PERSONA WIRING T2 (CONTRACTOR authoring) — proof that the 👷‍♂️ CONTRACTOR
// creating/assigning/editing a task is LIVE on the SINGLE unified `tasksProvider`
// (Wave T1 collapsed the dual engine into one; Wave T2 adds the contractor's
// authoring methods to `TasksNotifier`). The contractor is the main app (the
// 📋 משימות screen entered from projects_screen), NOT a board.
//
// The headline behavior: a contractor-CREATED task → the WORKER sees it live.
// The worker board scopes the live `tasksProvider` by the int worker index
// (`t.worker == worker` — worker_app_screen `_TasksTab._bucket` / the worker
// profile stats; the exact predicate guarded in worker_task_scope_test.dart), so
// a task minted for `worker:0` (רן) must appear in רן's scoped view — with a
// fresh id and the contractor's stamped employerId/assignedWorkerUid.
//
// Engine-only (Firebase-free): `TasksNotifier(persist: false)` over a clean
// verbatim seed (the task_clock_test.dart / tasks_smart_project idiom) — so the
// minted id is deterministic (max(seed ids 1..5)+1 = 6) and no SharedPreferences
// overlay leaks across runs. Exercises the FROZEN T2a API:
//   createTask({name, detail, days, steps, worker, assignedWorkerUid, employerId}) → int
//   editTask(int, {name?, detail?, days?, steps?})
//   assignTask(int, {worker?, assignedWorkerUid?})
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// The exact scope predicate the worker board applies over `tasksProvider`
  /// (`_TasksTab` + the worker profile both filter `t.worker == worker`) —
  /// mirrored from worker_task_scope_test.dart so this proves the SAME path.
  List<TaskItem> scoped(List<TaskItem> all, int worker) =>
      all.where((t) => t.worker == worker).toList();

  group('contractor task authoring → worker sees it live (T2)', () {
    test(
        'createTask mints a task on tasksProvider with a fresh id + stamped '
        'employerId/assignedWorkerUid, and it appears in the worker-filtered '
        'view (HEADLINE: contractor-created → worker-sees-live)', () {
      final n = TasksNotifier(persist: false);

      // Clean verbatim seed: ids 1..5, רן (worker 0) owns 1/2/5 (the scope
      // guard's seed truth). No task named 'התקנת כיור' exists yet.
      final seedIds = n.state.map((t) => t.id).toList();
      expect(seedIds, [1, 2, 3, 4, 5],
          reason: 'the verbatim §6 seed is 5 tasks (אין המצאות)');
      expect(n.state.any((t) => t.name == 'התקנת כיור'), isFalse);

      // The CONTRACTOR authors a new task for רן (worker 0), stamping the
      // contractor's employerId + the worker's server-ready uid (write-when-
      // non-empty, mirroring Order.contractorUid).
      final newId = n.createTask(
        name: 'התקנת כיור',
        assignedWorkerUid: 'uid-ran',
        employerId: 'contractor-demo',
        worker: 0,
      );

      // A FRESH id past the seed max (max(1..5)+1 = 6) — no collision with the
      // verbatim seed.
      expect(newId, 6, reason: 'createTask mints max(existing ids)+1');
      expect(seedIds.contains(newId), isFalse, reason: 'the id is fresh');

      // It is ON the single unified tasksProvider (the engine state).
      final created = n.state.firstWhere((t) => t.id == newId);
      expect(created.name, 'התקנת כיור');
      expect(created.worker, 0, reason: 'addressed to רן (the demo fallback)');

      // The contractor's identity is STAMPED (server-ready fields).
      expect(created.employerId, 'contractor-demo',
          reason: 'the contractor stamps the employer it owns the task for');
      expect(created.assignedWorkerUid, 'uid-ran',
          reason: 'the contractor stamps who the task is assigned to');

      // It is NOT a terminal/closed status — a freshly authored task is live
      // work the worker can see and act on (not already done/rejected).
      expect(created.status, isNot('done'));
      expect(created.status, isNot('rejected'));

      // HEADLINE: it appears in רן's scoped worker view (worker index 0), live —
      // the contractor-created task reached the worker with zero extra wiring.
      final ranView = scoped(n.state, 0);
      expect(ranView.map((t) => t.id), contains(newId),
          reason: 'a task minted for worker 0 shows in רן\'s board scope');
      expect(ranView.firstWhere((t) => t.id == newId).name, 'התקנת כיור');

      // ...and it does NOT leak into the OTHER worker's scope (worker 1, עומר).
      expect(scoped(n.state, 1).map((t) => t.id), isNot(contains(newId)),
          reason: 'a worker-0 task must not appear in worker 1\'s scope');
    });

    test('editTask patches name/detail live on the unified provider', () {
      final n = TasksNotifier(persist: false);
      final id = n.createTask(
        name: 'התקנת כיור',
        detail: 'טיוטה',
        assignedWorkerUid: 'uid-ran',
        employerId: 'contractor-demo',
        worker: 0,
      );
      TaskItem byId(int x) => n.state.firstWhere((t) => t.id == x);

      expect(byId(id).name, 'התקנת כיור');
      expect(byId(id).detail, 'טיוטה');

      // The contractor edits the task in place — a live patch on tasksProvider.
      n.editTask(id, name: 'התקנת כיור + סיפון', detail: 'כולל סיפון ובדיקת אטימה');

      expect(byId(id).name, 'התקנת כיור + סיפון',
          reason: 'editTask patches the name live');
      expect(byId(id).detail, 'כולל סיפון ובדיקת אטימה',
          reason: 'editTask patches the detail live');
      // Identity + assignment are untouched by a name/detail patch.
      expect(byId(id).worker, 0);
      expect(byId(id).assignedWorkerUid, 'uid-ran');
      expect(byId(id).employerId, 'contractor-demo');
    });

    test('assignTask re-points the worker index + assignedWorkerUid (live re-scope)',
        () {
      final n = TasksNotifier(persist: false);
      final id = n.createTask(
        name: 'התקנת כיור',
        assignedWorkerUid: 'uid-ran',
        employerId: 'contractor-demo',
        worker: 0,
      );
      List<TaskItem> scopedFor(int w) => scoped(n.state, w);

      // Starts in רן's scope (worker 0), not עומר's (worker 1).
      expect(scopedFor(0).map((t) => t.id), contains(id));
      expect(scopedFor(1).map((t) => t.id), isNot(contains(id)));

      // The contractor REASSIGNS the task to עומר (worker 1, uid-omer).
      n.assignTask(id, worker: 1, assignedWorkerUid: 'uid-omer');

      final t = n.state.firstWhere((x) => x.id == id);
      expect(t.worker, 1, reason: 'assignTask re-points the worker index');
      expect(t.assignedWorkerUid, 'uid-omer',
          reason: 'assignTask re-points the server-ready uid');

      // The live re-scope: it left רן's view and entered עומר's.
      expect(scopedFor(0).map((t) => t.id), isNot(contains(id)),
          reason: 'the reassigned task left the old worker\'s scope');
      expect(scopedFor(1).map((t) => t.id), contains(id),
          reason: 'the reassigned task entered the new worker\'s scope live');
    });
  });
}
