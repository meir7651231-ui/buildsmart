// SHARED WORKER-TASKS ENGINE — the live state that makes the 🦺 worker's task
// activity reflect to the 👔 manager (cross-persona wiring W3). This is the
// Flutter/Riverpod lift of the worker demo data (`kPersonaTasks`,
// `lib/data/persona_data.dart`) from a STATIC const into a single live list both
// roles read & write, exactly like the orders engine did for `SYS_ORDERS`.
//
// The approval bridge is already encoded in the task statuses (proto 06
// `taskStatusInfo` [L8048]):
//   • `active`/`rejected` → the worker can SUBMIT it (📸 ממתין לאישור = `review`).
//   • `review`            → the manager APPROVES (✅ אושר = `done`) or REJECTS it
//                           (↩️ נדחה — לתקן = `rejected`, back to the worker).
//
// Because the provider is SHARED, a worker submit immediately surfaces the task
// in the manager's approvals view, and a manager approve/reject reflects live on
// the worker's own reading — no refresh. When an approved task carries an
// [PersonaTask.orderId], the approval also `advance`s that order on the shared
// `ordersEngineProvider`, so a completed install moves its order live too.

import 'package:buildsmart/data/persona_data.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The live worker-tasks list — seeded from the verbatim [kPersonaTasks] so
/// every existing number/string is byte-for-byte identical until a status moves.
class WorkerTasksNotifier extends StateNotifier<List<PersonaTask>> {
  WorkerTasksNotifier(this._ref) : super(kPersonaTasks);

  final Ref _ref;

  /// Replace the status of the task with [id] (no-op on an unknown id or when
  /// the status is already [status]) — the single mutation primitive.
  void _setStatus(int id, String status) {
    final idx = state.indexWhere((t) => t.id == id);
    if (idx < 0 || state[idx].status == status) return;
    state = [
      for (var i = 0; i < state.length; i++)
        if (i == idx) state[i].copyWith(status: status) else state[i],
    ];
  }

  /// WORKER action — "שלח לאישור": submit a task for the manager's approval.
  /// Allowed only from a worker-owned status (`active` or `rejected`, the
  /// current/rejected bucket); moves it to `review` (📸 ממתין לאישור). A no-op if
  /// the task is already submitted/approved (`review`/`done`) or still queued
  /// (`pending`).
  void submitForReview(int id) {
    final idx = state.indexWhere((t) => t.id == id);
    if (idx < 0) return;
    final cur = state[idx].status;
    if (cur != 'active' && cur != 'rejected') return;
    _setStatus(id, 'review');
  }

  /// MANAGER action — approve a pending task: `review` → `done` (✅ אושר). If the
  /// task is bound to an order ([PersonaTask.orderId]), the approval also
  /// advances that order one stage on the SHARED [ordersEngineProvider] (so a
  /// completed install moves the order live). A no-op unless the task is in
  /// `review`.
  void approve(int id) {
    final idx = state.indexWhere((t) => t.id == id);
    if (idx < 0 || state[idx].status != 'review') return;
    final orderId = state[idx].orderId;
    _setStatus(id, 'done');
    if (orderId != null) {
      _ref.read(ordersEngineProvider.notifier).advance(orderId);
    }
  }

  /// MANAGER action — reject a pending task: `review` → `rejected`
  /// (↩️ נדחה — לתקן), bouncing it back to the worker's current bucket so the
  /// worker can fix and re-submit. A no-op unless the task is in `review`.
  void reject(int id) {
    final idx = state.indexWhere((t) => t.id == id);
    if (idx < 0 || state[idx].status != 'review') return;
    _setStatus(id, 'rejected');
  }

  /// Reset to the verbatim seed (tests / a future "demo reset").
  void resetToSeed() => state = kPersonaTasks;
}

/// The shared worker-tasks provider — the single live list the worker screen and
/// the manager's approvals view both read.
final workerTasksProvider =
    StateNotifierProvider<WorkerTasksNotifier, List<PersonaTask>>(
  WorkerTasksNotifier.new,
);

/// The tasks currently awaiting the manager's approval (`review`), in id order —
/// the manager's "אישורי עובדים" queue, derived LIVE off [workerTasksProvider].
final pendingApprovalTasksProvider = Provider<List<PersonaTask>>((ref) {
  final tasks = ref.watch(workerTasksProvider);
  return tasks.where((t) => t.status == 'review').toList()
    ..sort((a, b) => a.id.compareTo(b.id));
});
