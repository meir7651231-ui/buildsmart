// FORWARDING SHIM (Wave T1) — `workerTasksProvider` USED to be a second, parallel
// task engine (a lean `List<PersonaTask>` held by its own StateNotifier, kept in
// sync with the rich `tasksProvider` by a fragile dual-write + post-frame mirror).
// Wave T1 collapsed the two engines into ONE: `state/tasks_engine.dart`
// (`tasksProvider` / `TasksNotifier`) is now the SINGLE source of truth.
//
// This file is preserved as a THIN forwarding shim so EVERY existing consumer +
// import still compiles and behaves, even before T1b migrates them to the unified
// provider (a missed call must not break the tree):
//   • `workerTasksProvider` is now a LIVE PROJECTION of `tasksProvider` — its
//     `List<PersonaTask>` is derived from the unified `List<TaskItem>` (same task
//     identities/statuses), re-projected whenever the unified engine changes.
//   • `WorkerTasksNotifier`'s mutations (`submitForReview`/`approve`/`reject`/
//     `resetToSeed`) FORWARD to `TasksNotifier`, so there is no second store and
//     no dual-write to reconcile. The `orderId`→`ordersEngineProvider.advance`-on-
//     approve effect now lives in `TasksNotifier.approve` (folded in), so the
//     forwarded approve still advances a bound order — exactly once (the unified
//     engine's `review`-status guard makes any repeated/dual call a no-op).
//   • `pendingApprovalTasksProvider` survives, deriving its `List<PersonaTask>`
//     `review` queue off the unified engine (sibling of `tasksPendingReviewProvider`
//     in tasks_engine.dart, which exposes the same queue as `List<TaskItem>`).
//
// No new behavior, no new persistence: this shim owns NO state and NO prefs key
// (`bs.tasks-screen.v1` in the unified engine is the only task overlay now).

import 'package:buildsmart/data/persona_data.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Project ONE unified [TaskItem] down to the lean [PersonaTask] shape the legacy
/// `workerTasksProvider` consumers expect. `steps` collapses to its COUNT
/// (PersonaTask carries an int; the rich engine carries the strings), and the
/// server-ready identity fields ride along unchanged.
PersonaTask _asPersonaTask(TaskItem t) => PersonaTask(
      id: t.id,
      name: t.name,
      worker: t.worker,
      status: t.status,
      days: t.days,
      steps: t.steps.length,
      note: t.note,
      orderId: t.orderId,
      employerId: t.employerId,
      assignedWorkerUid: t.assignedWorkerUid,
    );

/// Legacy SharedPreferences key (now UNUSED — the unified engine persists under
/// `bs.tasks-screen.v1`). Kept as a public const so any external reference still
/// resolves; the shim writes nothing here.
const String kWorkerTasksKey = 'bs.worker-tasks.v1';

/// THIN forwarding shim over the unified [TasksNotifier] (Wave T1). Holds no
/// state of its own: its [state] is a live projection of [tasksProvider], and
/// every mutation forwards to the single engine. The constructor signature
/// (`WorkerTasksNotifier(ref, {persist})`) is preserved so existing call sites
/// (`site_local.dart`, the legacy tests) keep compiling unchanged.
class WorkerTasksNotifier extends StateNotifier<List<PersonaTask>> {
  WorkerTasksNotifier(this._ref, {this.persist = true}) : super(const []) {
    // Mirror the unified engine live (the proven `SysOrdersNotifier` pattern):
    // every `tasksProvider` change re-projects this view, and `fireImmediately`
    // seeds it from the engine's current state at construction — so the worker
    // board + manager queue reading THIS provider stay live with zero dual-write.
    _ref.listen<List<TaskItem>>(
      tasksProvider,
      (_, next) => state = [for (final t in next) _asPersonaTask(t)],
      fireImmediately: true,
    );
  }

  final Ref _ref;

  /// Retained for call-site compatibility (the unified engine owns persistence
  /// now; this shim persists nothing). Reading the unified notifier with
  /// `persist:false` would require a separate container in tests, so the flag is
  /// intentionally inert here.
  final bool persist;

  TasksNotifier get _engine => _ref.read(tasksProvider.notifier);

  /// WORKER "שלח לאישור" — forwards to [TasksNotifier.submitForReview]
  /// (`active`/`rejected` → `review`, else no-op; identity left to the unified
  /// engine's optional stamping params). Signature unchanged for legacy callers.
  void submitForReview(int id) => _engine.submitForReview(id);

  /// MANAGER approve — forwards to [TasksNotifier.approve] (`review` → `done`).
  /// The order-advance fold + coin/bell side-effects now live in the unified
  /// engine; the `review`-status guard there makes a repeated/dual call a no-op.
  void approve(int id) => _engine.approve(id);

  /// MANAGER reject — forwards to [TasksNotifier.reject] (`review` → `rejected`).
  void reject(int id) => _engine.reject(id);

  /// Reset to the verbatim seed — forwards to the unified engine's reset.
  void resetToSeed() => _engine.resetToSeed();
}

/// The worker-tasks provider — a FORWARDING SHIM over the unified [tasksProvider]
/// (Wave T1). Same `StateNotifierProvider<WorkerTasksNotifier, List<PersonaTask>>`
/// shape as before, so every `.notifier`/read consumer keeps working; under the
/// hood it projects + forwards to the single engine (no second store).
final workerTasksProvider =
    StateNotifierProvider<WorkerTasksNotifier, List<PersonaTask>>(
  (ref) => WorkerTasksNotifier(ref),
);

/// The tasks currently awaiting the manager's approval (`review`), in id order —
/// the manager's "אישורי עובדים" queue, derived LIVE off the unified
/// [tasksProvider] and projected to [PersonaTask]. Sibling of
/// `tasksPendingReviewProvider` (tasks_engine.dart), which exposes the SAME queue
/// as `List<TaskItem>`.
final pendingApprovalTasksProvider = Provider<List<PersonaTask>>((ref) {
  final tasks = ref.watch(tasksProvider);
  return [
    for (final t in tasks)
      if (t.status == 'review') _asPersonaTask(t),
  ]..sort((a, b) => a.id.compareTo(b.id));
});

/// The tasks a WORKER has PROPOSED (`proposed`), awaiting the contractor's
/// approval — the contractor's PROPOSAL-approval queue (Wave G1a). Mirrors
/// [pendingApprovalTasksProvider] exactly (same `_asPersonaTask` projection
/// carrying worker/employerId/assignedWorkerUid, same id-order sort), but
/// projects the `'proposed'` bucket instead of `'review'`. UNSCOPED like its
/// sibling — the contractor UI in G1c scopes it by employerId. The worker
/// authored these via [TasksNotifier.proposeTask]; the contractor flips them
/// with [TasksNotifier.approveProposal]/[TasksNotifier.rejectProposal].
final pendingProposalsProvider = Provider<List<PersonaTask>>((ref) {
  final tasks = ref.watch(tasksProvider);
  return [
    for (final t in tasks)
      if (t.status == 'proposed') _asPersonaTask(t),
  ]..sort((a, b) => a.id.compareTo(b.id));
});
