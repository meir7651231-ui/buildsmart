// A5 — the worker task board folds a 'proposed' task (a worker proposal
// awaiting the contractor's approval) into the בתור (pending) group, NOT a
// separate group. Every engine status maps to exactly one group, so the group
// counts sum to the worker's total. Pure: exercises the extracted
// WorkerTaskBoardScreen.groupByStatus, no widget pump needed.
import 'package:buildsmart/screens/worker_task_board_screen.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:flutter_test/flutter_test.dart';

TaskItem _t(int id, String status) => TaskItem(
      id: id,
      name: 'task-$id',
      detail: '',
      worker: 0,
      status: status,
      days: 1,
      steps: const [],
    );

void main() {
  test("'proposed' folds into בתור (A5); every status maps to one group", () {
    final tasks = [
      _t(1, 'proposed'),
      _t(2, 'pending'),
      _t(3, 'active'),
      _t(4, 'done'),
    ];
    final groups = WorkerTaskBoardScreen.groupByStatus(tasks);

    final queue = groups.firstWhere((g) => g.title.contains('בתור'));
    expect(
      queue.tasks.map((t) => t.id),
      containsAll(<int>[1, 2]),
      reason: 'the proposed task (1) sits beside the pending task (2) in בתור',
    );
    // there is NO separate proposed/הוצעה group
    expect(
      groups.any((g) =>
          g.title.contains('הוצע') ||
          g.title.toLowerCase().contains('propos')),
      isFalse,
      reason: 'proposals fold into בתור, not a group of their own',
    );
    // every task lands in exactly one group → counts sum to the total
    expect(
      groups.fold<int>(0, (a, g) => a + g.tasks.length),
      tasks.length,
      reason: 'no task is dropped and none is double-counted',
    );
  });
}
