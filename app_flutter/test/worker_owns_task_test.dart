// Wave T3 (increment 2b) — the OR-tolerant worker-board predicate. Pins: (1) with
// an EMPTY uid (OFF / demo session) it is EXACTLY `t.worker == index` (byte-
// identical to the pre-T3 filter, in both directions), and (2) with a real uid it
// ALSO admits a task assigned by uid even when its demo `worker` index differs
// (the contractor-assigned case the scoped server repo relies on).
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:flutter_test/flutter_test.dart';

TaskItem _t({required int worker, String assignedWorkerUid = ''}) => TaskItem(
      id: 1,
      name: 'x',
      detail: '',
      worker: worker,
      status: 'pending',
      days: 1,
      steps: const [],
      assignedWorkerUid: assignedWorkerUid,
    );

void main() {
  group('#taskT3-2b workerOwnsTask', () {
    test('empty uid ⇒ pure int-index filter (byte-identical OFF)', () {
      expect(workerOwnsTask(_t(worker: 0), 0, ''), isTrue);
      expect(workerOwnsTask(_t(worker: 1), 0, ''), isFalse);
      // a uid on the task is IGNORED when the viewer has no uid.
      expect(workerOwnsTask(_t(worker: 1, assignedWorkerUid: 'u9'), 0, ''),
          isFalse);
    });

    test('real uid ⇒ admits a uid-assigned task despite a mismatched index', () {
      // contractor-assigned: worker index is the 0 default, but the uid matches.
      expect(workerOwnsTask(_t(worker: 0, assignedWorkerUid: 'u9'), 5, 'u9'),
          isTrue);
      // still admits the demo-index match too (OR-tolerant).
      expect(workerOwnsTask(_t(worker: 5), 5, 'u9'), isTrue);
      // neither index nor uid match → not theirs.
      expect(workerOwnsTask(_t(worker: 3, assignedWorkerUid: 'other'), 5, 'u9'),
          isFalse);
    });
  });
}
