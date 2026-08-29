// Wave T3 (increment 2c) — the CROSS-PARTY CLOSURE the whole identity migration
// exists to create: when the contractor stamps a task with the picked worker's
// REAL uid (createTask assignedWorkerUid) + their own employerId, the worker's
// uid-scoped board predicate (workerOwnsTask) admits it EVEN THOUGH the demo int
// `worker` index is the 0 default. This is exactly what the server's
// assignedWorkerUid-scoped query relies on. Engine-level (no flag / no Firebase).
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('#taskT3-2c contractor→worker uid closure', () {
    test('createTask stamps the picked worker uid + employer uid', () {
      final n = TasksNotifier(persist: false);
      final id = n.createTask(
        name: 'התקנת דוד',
        assignedWorkerUid: 'wrk-9',
        employerId: 'emp-1',
        // worker index left at the 0 default — uid is the server addressing.
      );
      final t = n.state.firstWhere((x) => x.id == id);
      expect(t.assignedWorkerUid, 'wrk-9');
      expect(t.employerId, 'emp-1');
      expect(t.worker, 0); // the demo index is NOT the addressing on the server
      expect(t.status, 'pending');
      expect(t.createdBy, 'contractor');
    });

    test('the worker board predicate admits it by uid despite index mismatch',
        () {
      final n = TasksNotifier(persist: false);
      final id = n.createTask(name: 'x', assignedWorkerUid: 'wrk-9');
      final t = n.state.firstWhere((x) => x.id == id);
      // Worker "wrk-9" is viewing as index 5 (their demo index) — the task's
      // index is 0, but the uid matches, so it IS on their board.
      expect(workerOwnsTask(t, 5, 'wrk-9'), isTrue);
      // A different worker (uid + index both mismatched) does NOT see it.
      expect(workerOwnsTask(t, 5, 'other-uid'), isFalse);
    });

    test('assignTask (re)stamps the worker uid (write-when-non-empty)', () {
      final n = TasksNotifier(persist: false);
      final id = n.createTask(name: 'x'); // unassigned (no uid)
      n.assignTask(id, assignedWorkerUid: 'wrk-7');
      final t = n.state.firstWhere((x) => x.id == id);
      expect(t.assignedWorkerUid, 'wrk-7');
      expect(workerOwnsTask(t, 99, 'wrk-7'), isTrue);
    });
  });
}
