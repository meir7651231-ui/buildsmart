// TASKS ENGINE (T3.A · proto §6 [L8023-8200]) — the full משימות screen state:
// the 5-state machine (pending · active · review · done · rejected), the
// manager/worker views, AUTO-ADVANCE (a worker submit promotes that worker's
// next pending task to active), and the WORK_LOG day buckets.
//
// REUSE: this is the same shared-list / 5-state pattern as
// `state/worker_tasks_engine.dart` (the cross-persona W3 bridge) and the
// orders-engine. The existing `workerTasksProvider` powers the 🦺 worker app +
// the manager's approvals badge; THIS engine powers the full §6 משימות SCREEN,
// which additionally needs the verbatim per-task `detail` + `steps` strings and
// the prototype's auto-advance on submit (`taskActionClick` :8133-8145) — fields
// the lean `PersonaTask` doesn't carry. The state machine + statuses are
// byte-identical (`taskStatusInfo` [L8048] = `kTaskStatusLabel`).
//
// VERBATIM seeds: names/workers/days from `data/persona_data.dart`
// (`kPersonaTasks` / `kWorkers`), step lists from `data/phaseb_seeds.dart`
// (`kTaskSteps`), `detail` strings from the prototype §6 (inlined below — they
// live only in the prototype `TASKS` array, not yet in a Dart seed). WORK_LOG
// history from `kWorkLog`. No string invented (R6/R8).

import 'dart:convert';

import 'package:buildsmart/data/persona_data.dart';
import 'package:buildsmart/data/phaseb_seeds.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:buildsmart/state/rewards_state.dart';
import 'package:buildsmart/state/worker_notifs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Verbatim per-task `detail` strings — proto §6 `TASKS[i].detail` [L8024-8033].
/// Keyed by task id (1..5). These live only in the prototype array; inlined here
/// (the only place the §6 screen needs them).
const Map<int, String> kTaskDetail = {
  1: 'חיבור צנרת PEX מהדוד לנקודות. לוודא אטימה בכל חיבור.',
  2: 'התקנת המיכל בקיר לפי הסימון. בדיקת מפלס.',
  3: 'מריחת 2 שכבות איטום + חיזוק פינות.',
  4: 'מיקום הנקז לפי השיפוע. חיבור לקו ניקוז 50 מ"מ.',
  5: 'התקנת הברז וחיבור צינורות גמישים דרך ברזי ניל.',
};

/// One live §6 task — name/worker/days/status from [kPersonaTasks], the verbatim
/// `detail` from [kTaskDetail], step strings from [kTaskSteps]. `photo`/`note`
/// are the worker's runtime report (proto `TASKS[i].photo/.note`).
class TaskItem {
  const TaskItem({
    required this.id,
    required this.name,
    required this.detail,
    required this.worker,
    required this.status,
    required this.days,
    required this.steps,
    this.photo,
    this.note = '',
    this.startedAt,
    this.completedAt,
    this.doneSteps = const {},
    this.orderId,
    this.employerId = '',
    this.assignedWorkerUid = '',
  });

  final int id;
  final String name;
  final String detail;
  final int worker; // index into kWorkers (demo fallback identity)
  final String status; // pending·active·review·done·rejected
  final int days;
  final List<String> steps;

  /// Optional link to a shared-engine order (`Order.id`, e.g. `BS-1040`),
  /// carried verbatim from the [kPersonaTasks] seed. When a linked task is
  /// APPROVED, [TasksNotifier.approve] advances that order one stage on the
  /// shared `ordersEngineProvider` (the W3 fold) — so a completed install moves
  /// its order live. Null for tasks with no order binding (the default).
  final String? orderId;

  /// SERVER-READY identity (Wave T1, additive) — the employer (contractor) this
  /// task belongs to, mirroring `Order.contractorUid`. Empty on the verbatim
  /// demo seed; stamped write-when-non-empty when a real session acts (so the
  /// seed + overlay stay byte-identical on the offline/demo path).
  final String employerId;

  /// SERVER-READY identity (Wave T1, additive) — the uid of the worker the task
  /// is assigned to. Empty on the demo seed (the int [worker] is the fallback);
  /// stamped write-when-non-empty when a real worker first acts on it.
  final String assignedWorkerUid;

  /// The worker's proof photo (#85ב): a REAL data-URL
  /// ('data:image/...;base64,…' captured via `services/task_photo.dart`) once
  /// the worker shoots one, the legacy `'demo'` marker for seeded/placeholder
  /// photos, or null when nothing is attached (proto `photo`). Renderers must
  /// handle both forms (data-URL → Image.memory · 'demo' → honest
  /// placeholder — see the submission-history rows in
  /// `screens/worker_reports_tab.dart`).
  final String? photo;
  final String note;

  /// ⏱️ TASK CLOCK (#85ו) — runtime-only stamps, null on the verbatim seed
  /// (no invented history): 'התחל עבודה' ([TasksNotifier.startWork]) sets
  /// [startedAt]; the worker submit sets [completedAt]; a manager reject
  /// clears [completedAt] (the task is back in work).
  final DateTime? startedAt;
  final DateTime? completedAt;

  /// ☑️ Per-step completion (#3) — the indexes into [steps] the worker ticked.
  /// Lives on the engine (NOT widget state) so the checklist survives sheet
  /// close/reopen and an app restart (persisted in the overlay as a
  /// `List<int>`). Empty on the verbatim seed.
  final Set<int> doneSteps;

  TaskItem copyWith({
    String? status,
    Object? photo = _sentinel,
    String? note,
    Object? startedAt = _sentinel,
    Object? completedAt = _sentinel,
    Set<int>? doneSteps,
    String? employerId,
    String? assignedWorkerUid,
  }) =>
      TaskItem(
        id: id,
        name: name,
        detail: detail,
        worker: worker,
        status: status ?? this.status,
        days: days,
        steps: steps,
        photo: photo == _sentinel ? this.photo : photo as String?,
        note: note ?? this.note,
        startedAt:
            startedAt == _sentinel ? this.startedAt : startedAt as DateTime?,
        completedAt: completedAt == _sentinel
            ? this.completedAt
            : completedAt as DateTime?,
        doneSteps: doneSteps ?? this.doneSteps,
        // [orderId] is seed-immutable (never mutated at runtime) — propagate.
        orderId: orderId,
        employerId: employerId ?? this.employerId,
        assignedWorkerUid: assignedWorkerUid ?? this.assignedWorkerUid,
      );

  static const _sentinel = Object();
}

/// Build the verbatim §6 seed by joining the existing Dart seeds (R6 reuse).
List<TaskItem> _seedTasks() => [
      for (final t in kPersonaTasks)
        TaskItem(
          id: t.id,
          name: t.name,
          detail: kTaskDetail[t.id] ?? '',
          worker: t.worker,
          status: t.status,
          days: t.days,
          steps: kTaskSteps[t.id] ?? const [],
          // proto seeds photo='demo' for the review/done tasks (3,4); null else.
          photo: (t.status == 'review' || t.status == 'done') ? 'demo' : null,
          note: t.note,
          // W3 fold (Wave T1): carry the seed's order binding so the unified
          // notifier's approve can advance the bound order. Seed-derived only
          // (not persisted) → the overlay payload stays byte-identical.
          orderId: t.orderId,
        ),
    ];

const String kTasksScreenKey = 'bs.tasks-screen.v1';

/// ⏱️ #85ו cross-cluster side-map MIRROR of the clock stamps —
/// `{taskId: {startedAt: iso, completedAt: iso}}`. The reports tab
/// (`screens/worker_reports_tab.dart`, key `kTaskClockKey`) reads it
/// read-only; the engine's [TasksNotifier._persist] is the writer ("the
/// writers live with the engines"). Source of truth stays on [TaskItem].
const String kTaskClockSideMapKey = 'bs.task-clock.v1';

/// 📝 #85ו cross-cluster side-map of manager rejection reasons —
/// `{taskId: reason}`. Read by the reports tab ("דחיות + סיבה",
/// `kTaskRejectNoteKey` there); written by [TasksNotifier.reject] when the
/// manager actually gave a reason (no invented reason otherwise).
const String kTaskRejectNoteSideMapKey = 'bs.task-reject-note.v1';

/// 🪙 DEMO (#85ו): coins credited to the rewards balance per manager-approved
/// task. A fixed demo tariff — the real per-task value comes with the server.
const int kTaskApprovalCoins = 20;

class TasksNotifier extends StateNotifier<List<TaskItem>> {
  TasksNotifier({this.persist = true, Ref? ref})
      : _ref = ref,
        super(_seedTasks()) {
    if (persist) _load();
  }

  final bool persist;

  /// Engine→app hooks (#85ו: coins + worker notifications on REAL
  /// transitions). Null in unit tests (`TasksNotifier(persist: false)`) —
  /// hooks are skipped and the state machine behaves exactly as before.
  final Ref? _ref;

  bool _loaded = false;

  /// SERVER-SWAP seam (Wave T1, EMPTY): the bound Firestore-backed tasks repo,
  /// or null on the local/demo path (no Firebase → this engine itself stays the
  /// store, byte-identical). Typed `dynamic` so no Firebase symbol is imported
  /// here — Wave T3 fills `tasks_firebase.dart` + binds via [bindRemote],
  /// mirroring `orders_engine.dart`. Unused until then.
  dynamic _remote;

  /// Persist a compact `{id: {status, photo, note, startedAt, completedAt,
  /// doneSteps}}` overlay onto the verbatim seed — resilient to seed edits
  /// (the worker-tasks-engine pattern). `doneSteps` (#3) rides the overlay as
  /// a plain `List<int>` of ticked step indexes.
  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(kTasksScreenKey);
      if (raw == null || raw.isEmpty) {
        _loaded = true;
        return;
      }
      final m = jsonDecode(raw) as Map<String, dynamic>;
      if (!_loaded) {
        super.state = [
          for (final t in _seedTasks())
            if (m['${t.id}'] is Map)
              t.copyWith(
                status: (m['${t.id}'] as Map)['status'] as String?,
                photo: (m['${t.id}'] as Map)['photo'] as String?,
                note: (m['${t.id}'] as Map)['note'] as String?,
                startedAt: DateTime.tryParse(
                    (m['${t.id}'] as Map)['startedAt'] as String? ?? ''),
                completedAt: DateTime.tryParse(
                    (m['${t.id}'] as Map)['completedAt'] as String? ?? ''),
                // ☑️ #3 — restore the ticked steps; a pre-#3 payload simply
                // has no key (null → keep the empty default).
                doneSteps: (m['${t.id}'] as Map)['doneSteps'] is List
                    ? {
                        for (final s
                            in (m['${t.id}'] as Map)['doneSteps'] as List)
                          if (s is num) s.toInt(),
                      }
                    : null,
                // SERVER-READY identity (Wave T1) — restore a stamped uid; a
                // pre-T1 / demo payload has no key (null → keep '' default), so
                // the seed stays byte-identical.
                employerId: (m['${t.id}'] as Map)['employerId'] as String?,
                assignedWorkerUid:
                    (m['${t.id}'] as Map)['assignedWorkerUid'] as String?,
              )
            else
              t,
        ];
        _loaded = true;
      }
    } on Object catch (_) {
      _loaded = true;
    }
  }

  Future<void> _persist() async {
    if (!persist) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        kTasksScreenKey,
        jsonEncode({
          for (final t in state)
            '${t.id}': {
              'status': t.status,
              'photo': t.photo,
              'note': t.note,
              'startedAt': t.startedAt?.toIso8601String(),
              'completedAt': t.completedAt?.toIso8601String(),
              // ☑️ #3 — the ticked step indexes, sorted for a stable payload.
              'doneSteps': t.doneSteps.toList()..sort(),
              // SERVER-READY identity (Wave T1) — WRITE-WHEN-NON-EMPTY (the uid
              // economy): the keys appear ONLY once a real session stamps them,
              // so the verbatim demo seed's overlay payload stays byte-identical.
              if (t.employerId.isNotEmpty) 'employerId': t.employerId,
              if (t.assignedWorkerUid.isNotEmpty)
                'assignedWorkerUid': t.assignedWorkerUid,
            },
        }),
      );
      // ⏱️ #85ו: mirror the clock stamps into the bs.task-clock.v1 side-map
      // for the read-only consumer (worker_reports_tab.dart). Tasks with no
      // stamp are omitted — an empty/missing entry IS the honest "no
      // measurement" state there.
      await prefs.setString(
        kTaskClockSideMapKey,
        jsonEncode({
          for (final t in state)
            if (t.startedAt != null || t.completedAt != null)
              '${t.id}': {
                'startedAt': t.startedAt?.toIso8601String(),
                'completedAt': t.completedAt?.toIso8601String(),
              },
        }),
      );
    } on Object catch (_) {}
  }

  @override
  set state(List<TaskItem> value) {
    _loaded = true;
    super.state = value;
    _persist();
  }

  TaskItem? _byId(int id) {
    final i = state.indexWhere((t) => t.id == id);
    return i < 0 ? null : state[i];
  }

  void _patch(int id, TaskItem Function(TaskItem) f) {
    final idx = state.indexWhere((t) => t.id == id);
    if (idx < 0) return;
    state = [
      for (var i = 0; i < state.length; i++)
        if (i == idx) f(state[i]) else state[i],
    ];
  }

  /// WORKER attaches a proof photo — `taskUpload` (proto :8147). [photo] is
  /// the REAL captured data-URL ('data:image/...;base64,…', #85ב via
  /// `services/task_photo.dart`); the legacy 'demo' marker remains the default
  /// so older callers keep their honest placeholder rendering.
  void attachPhoto(int id, [String photo = 'demo']) =>
      _patch(id, (t) => t.copyWith(photo: photo));

  /// WORKER step checklist (#3) — toggle ONE step's done mark on the engine
  /// (the worker sheet's checkbox). Persists with the overlay, so the ticks
  /// survive sheet close/reopen and an app restart. A no-op on an unknown
  /// task or an out-of-range index.
  void toggleStep(int taskId, int stepIndex) {
    final t = _byId(taskId);
    if (t == null) return;
    if (stepIndex < 0 || stepIndex >= t.steps.length) return;
    _patch(taskId, (x) {
      final next = Set<int>.from(x.doneSteps);
      if (!next.add(stepIndex)) next.remove(stepIndex);
      return x.copyWith(doneSteps: next);
    });
  }

  /// WORKER 'התחל עבודה' (#85ו) — stamps the task clock. Allowed on the
  /// current bucket only (`active`/`rejected`); one-shot — the clock keeps
  /// counting through a reject-and-fix cycle so the elapsed figure stays one
  /// honest number. [submitForReview] stamps [TaskItem.completedAt].
  ///
  /// Identity (Wave T1, additive): [workerUid]/[employerId] are OPTIONAL — when
  /// a real session passes a non-empty value, the worker's first touch stamps
  /// [TaskItem.assignedWorkerUid]/[TaskItem.employerId] (write-when-non-empty).
  /// Null/empty (every existing caller + unit test) → no stamp, back-compat.
  /// The clock guard is unchanged: the stamp rides the same one-shot _patch, so
  /// it lands on the FIRST 'התחל עבודה' only (a re-entry returns before the patch).
  void startWork(int id, {String? workerUid, String? employerId}) {
    final t = _byId(id);
    if (t == null) return;
    if (t.status != 'active' && t.status != 'rejected') return;
    if (t.startedAt != null) return;
    _patch(
      id,
      (x) => _stampIdentity(
        x.copyWith(startedAt: DateTime.now()),
        workerUid: workerUid,
        employerId: employerId,
      ),
    );
  }

  /// Write-when-non-empty identity stamp (Wave T1) — mirrors the uid economy on
  /// `Order.contractorUid`: a non-empty [workerUid]/[employerId] overwrites the
  /// task's field; null/empty leaves it as-is (so the demo seed + overlay stay
  /// byte-identical on the offline path). Pure — returns the patched [TaskItem].
  TaskItem _stampIdentity(TaskItem t, {String? workerUid, String? employerId}) {
    final uid = workerUid?.trim();
    final emp = employerId?.trim();
    if ((uid == null || uid.isEmpty) && (emp == null || emp.isEmpty)) return t;
    return t.copyWith(
      assignedWorkerUid: (uid != null && uid.isNotEmpty) ? uid : null,
      employerId: (emp != null && emp.isNotEmpty) ? emp : null,
    );
  }

  /// WORKER "שלח לאישור" — `taskActionClick` (proto :8133-8145): a current task
  /// (`active`/`rejected`) → `review`; the photo defaults to 'demo' if missing;
  /// the worker's [note] is saved. AUTO-ADVANCE: that worker's next `pending`
  /// task becomes `active`. A no-op unless the task is in a worker-owned status.
  ///
  /// Identity (Wave T1, additive): [workerUid]/[employerId] are OPTIONAL — when
  /// non-empty (a real session), the submit stamps the task's
  /// [TaskItem.assignedWorkerUid]/[TaskItem.employerId] (write-when-non-empty).
  /// The `id`/`note` signature is FROZEN; null identity (existing callers +
  /// unit tests) → no stamp, fully back-compat.
  void submitForReview(int id,
      {String? note, String? workerUid, String? employerId}) {
    final t = _byId(id);
    if (t == null) return;
    if (t.status != 'active' && t.status != 'rejected') return;
    _patch(
      id,
      (x) => _stampIdentity(
        x.copyWith(
          status: 'review',
          photo: x.photo ?? 'demo',
          note: note ?? x.note,
          // ⏱️ task clock (#85ו): the submit stamps the completion time.
          completedAt: DateTime.now(),
        ),
        workerUid: workerUid,
        employerId: employerId,
      ),
    );
    // auto-advance: promote the same worker's next queued task.
    final next = state
        .where((x) => x.worker == t.worker && x.status == 'pending')
        .toList();
    if (next.isNotEmpty) {
      _patch(next.first.id, (x) => x.copyWith(status: 'active'));
      // 🔔 #85ו: the auto-advance IS the new-assignment event — the worker's
      // next queued task just became their live task.
      _ref?.read(workerNotifsProvider.notifier).addForWorker(
            t.worker,
            emoji: '📋',
            title: 'משימה חדשה הוקצתה',
            body: next.first.name,
          );
    }
  }

  /// MANAGER approve — `taskApprove` (proto :8149): `review` → `done` (✅ אושר).
  /// #85ו side-effects (skipped without a [_ref], i.e. in unit tests): 🪙 DEMO
  /// coins onto the rewards balance + a 🔔 runtime notification for the task's
  /// worker. Both fire only on the real review→done transition (the status
  /// guard), so a re-approve can never double-award.
  ///
  /// W3 ORDER FOLD (Wave T1): when the approved task is bound to an order
  /// ([TaskItem.orderId], carried from the seed), the approval also advances
  /// that order ONE stage on the shared [ordersEngineProvider] — folded in from
  /// the former `WorkerTasksNotifier.approve` so a completed install still moves
  /// its order live. The `review`-status guard above gates it, so a re-approve
  /// (e.g. the legacy dual-call from the manager dashboard) can never advance
  /// twice. Skipped without a [_ref] (unit tests with no provider graph).
  void approve(int id) {
    final t = _byId(id);
    if (t == null || t.status != 'review') return;
    final orderId = t.orderId;
    _patch(id, (x) => x.copyWith(status: 'done'));
    final r = _ref;
    if (r == null) return;
    if (orderId != null) {
      r.read(ordersEngineProvider.notifier).advance(orderId);
    }
    r.read(rewardsProvider.notifier).awardCoins(kTaskApprovalCoins);
    r.read(workerNotifsProvider.notifier).addForWorker(
          t.worker,
          emoji: '✅',
          title: 'המשימה אושרה — +$kTaskApprovalCoins מטבעות',
          body: t.name,
        );
  }

  /// MANAGER reject — `taskReject` (proto :8150): `review` → `rejected`, clearing
  /// the photo (proto sets `photo=null`) so the worker re-shoots. #85ו: also
  /// clears the completion stamp (the task is back in work) and notifies the
  /// worker — with the manager's [reason] when one was given (UI seam; no
  /// invented reason otherwise). A real reason is also mirrored into the
  /// [kTaskRejectNoteSideMapKey] side-map for the reports tab.
  void reject(int id, {String? reason}) {
    final t = _byId(id);
    if (t == null || t.status != 'review') return;
    _patch(
      id,
      (x) => x.copyWith(status: 'rejected', photo: null, completedAt: null),
    );
    final why = reason?.trim();
    if (why != null && why.isNotEmpty) _saveRejectNote(id, why);
    final r = _ref;
    if (r == null) return;
    r.read(workerNotifsProvider.notifier).addForWorker(
          t.worker,
          emoji: '🔁',
          title: (why == null || why.isEmpty)
              ? 'הוחזרה לתיקון — צלם שוב ושלח לאישור'
              : 'הוחזרה לתיקון: $why',
          body: t.name,
        );
  }

  /// Merge ONE manager rejection reason into the bs.task-reject-note.v1
  /// side-map (`{taskId: reason}`) — read by the reports tab ("דחיות + סיבה").
  /// Read-modify-write so earlier reasons for other tasks survive.
  Future<void> _saveRejectNote(int id, String reason) async {
    if (!persist) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(kTaskRejectNoteSideMapKey);
      final m = (raw == null || raw.isEmpty)
          ? <String, dynamic>{}
          : jsonDecode(raw) as Map<String, dynamic>;
      m['$id'] = reason;
      await prefs.setString(kTaskRejectNoteSideMapKey, jsonEncode(m));
    } on Object catch (_) {}
  }

  void resetToSeed() => state = _seedTasks();

  // ───────────────────────────────────────────────────────────────────────
  // CONTRACTOR AUTHORING (Wave T2a, ADDITIVE) — the employer creates / edits /
  // (re)assigns a task on the SINGLE [tasksProvider], so the worker board
  // (filtered by [TaskItem.worker] / [assignedWorkerUid]) reflects it LIVE.
  // These do NOT touch the seed/overlay/persist machinery above — they ride the
  // public `state` setter (which persists) exactly like the existing mutators.
  // ───────────────────────────────────────────────────────────────────────

  /// CONTRACTOR "משימה חדשה" — mint a fresh task and append it to the live list.
  /// The id is `max(existing ids)+1` (1 on an empty list); the initial status is
  /// the seed's not-yet-started bucket (`'pending'`, matching the [kPersonaTasks]
  /// queued seeds). [employerId]/[assignedWorkerUid] are stamped
  /// WRITE-WHEN-NON-EMPTY (the uid economy — empty leaves the field '' so the
  /// demo path stays byte-identical). The int [worker] is the demo-fallback
  /// addressing the worker board filters on. Returns the new task's id.
  int createTask({
    required String name,
    String detail = '',
    int days = 1,
    List<String> steps = const [],
    int worker = 0,
    String assignedWorkerUid = '',
    String employerId = '',
  }) {
    final id =
        state.isEmpty ? 1 : (state.map((t) => t.id).reduce((a, b) => a > b ? a : b) + 1);
    final emp = employerId.trim();
    final uid = assignedWorkerUid.trim();
    state = [
      ...state,
      TaskItem(
        id: id,
        name: name,
        detail: detail,
        worker: worker,
        status: 'pending',
        days: days,
        steps: steps,
        employerId: emp,
        assignedWorkerUid: uid,
      ),
    ];
    return id;
  }

  /// CONTRACTOR edit — patch a task's authored fields (name/detail/days/steps),
  /// leaving the runtime state (status/photo/note/clock/doneSteps/identity/order)
  /// untouched. A null arg keeps the current value. No-op on an unknown id.
  /// Builds a new [TaskItem] directly because [copyWith] (the worker-runtime
  /// patcher) intentionally does not expose these authored fields.
  void editTask(int id,
      {String? name, String? detail, int? days, List<String>? steps}) {
    _patch(
      id,
      (t) => TaskItem(
        id: t.id,
        name: name ?? t.name,
        detail: detail ?? t.detail,
        worker: t.worker,
        status: t.status,
        days: days ?? t.days,
        steps: steps ?? t.steps,
        photo: t.photo,
        note: t.note,
        startedAt: t.startedAt,
        completedAt: t.completedAt,
        doneSteps: t.doneSteps,
        orderId: t.orderId,
        employerId: t.employerId,
        assignedWorkerUid: t.assignedWorkerUid,
      ),
    );
  }

  /// CONTRACTOR (re)assign — point a task at a different worker. The int [worker]
  /// is the demo-fallback addressing (the worker board filters on it);
  /// [assignedWorkerUid] is the server-ready uid, stamped WRITE-WHEN-NON-EMPTY
  /// (empty/null leaves it unchanged). No-op on an unknown id. Both optional so a
  /// caller can move the demo index, stamp the uid, or both.
  void assignTask(int id, {int? worker, String? assignedWorkerUid}) {
    final uid = assignedWorkerUid?.trim();
    _patch(
      id,
      (t) => TaskItem(
        id: t.id,
        name: t.name,
        detail: t.detail,
        worker: worker ?? t.worker,
        status: t.status,
        days: t.days,
        steps: t.steps,
        photo: t.photo,
        note: t.note,
        startedAt: t.startedAt,
        completedAt: t.completedAt,
        doneSteps: t.doneSteps,
        orderId: t.orderId,
        employerId: t.employerId,
        assignedWorkerUid:
            (uid != null && uid.isNotEmpty) ? uid : t.assignedWorkerUid,
      ),
    );
  }

  /// SERVER-SWAP seam (Wave T1): bind the engine to the live Firestore-backed
  /// tasks repository — mirrors `orders_engine.dart:bindRemote` (bind-once,
  /// store the repo, immediate refresh). Wave T3 fills `tasks_firebase.dart`
  /// with `FirebaseTasksRepository` and starts the real-time listener inside
  /// [_refreshFromRemote]; nothing calls this on the local/demo path, so the
  /// engine stays the byte-identical store until then. Typed `dynamic` so no
  /// Firebase symbol is imported here.
  void bindRemote(dynamic repo) {
    /* SERVER-SWAP: Wave T3 fills via FirebaseTasksRepository, mirror
       orders_engine.bindRemote (bind-once + addListener(_refreshFromRemote)). */
    if (_remote != null) return; // bind once (provider-lifetime)
    _remote = repo;
    _refreshFromRemote();
  }

  /// SERVER-SWAP seam (Wave T1): rebuild engine state from the bound remote's
  /// SYNC snapshot — mirrors `orders_engine.dart:_refreshFromRemote`. No-op
  /// while unbound ([_remote] null, the local/demo path); Wave T3 fills the body
  /// (`state = _remote.all();`) so a store-side change lands live in the engine.
  void _refreshFromRemote() {
    if (_remote == null) return;
    /* SERVER-SWAP: Wave T3 — state = _remote.all() (public setter → persist). */
  }
}

final tasksProvider = StateNotifierProvider<TasksNotifier, List<TaskItem>>(
    (ref) => TasksNotifier(ref: ref));

/// Tasks awaiting the manager's approval (`review`), in id order — the manager
/// "📸 ממתין לאישור שלך" bucket, derived LIVE off [tasksProvider].
final tasksPendingReviewProvider = Provider<List<TaskItem>>((ref) {
  final tasks = ref.watch(tasksProvider);
  return tasks.where((t) => t.status == 'review').toList()
    ..sort((a, b) => a.id.compareTo(b.id));
});

/// ⏱️ Task-clock label (#85ו) — elapsed between [TaskItem.startedAt] and
/// [TaskItem.completedAt] (or NOW while the work is still open), as a natural
/// Hebrew duration. Null when the clock never started — callers hide the row
/// (no invented timing). A render-time snapshot, refreshed on rebuild.
String? taskClockLabel(TaskItem t) {
  final start = t.startedAt;
  if (start == null) return null;
  var d = (t.completedAt ?? DateTime.now()).difference(start);
  if (d.isNegative) d = Duration.zero;
  if (d.inMinutes < 1) return 'פחות מדקה';
  if (d.inMinutes < 60) return '${d.inMinutes} דק׳';
  if (d.inHours < 24) {
    final m = d.inMinutes % 60;
    return m == 0 ? '${d.inHours} שע׳' : '${d.inHours} שע׳ $m דק׳';
  }
  final h = d.inHours % 24;
  return h == 0 ? '${d.inDays} ימים' : '${d.inDays} ימים $h שע׳';
}

// ─────────────────────────────────────────────────────────────────────────────
// WORK LOG — `openTaskLog` (proto :8158-8180). The live "היום" bucket is the
// approved (done) tasks; below it the read-only history from [kWorkLog].
// ─────────────────────────────────────────────────────────────────────────────

/// The "היום" work-log day, derived live from approved tasks (proto :8159-8161).
/// Empty → a single placeholder row "אין עדיין משימות שאושרו היום".
WorkLogDay todayWorkLog(List<TaskItem> tasks) {
  final done = tasks.where((t) => t.status == 'done').toList();
  if (done.isEmpty) {
    return const WorkLogDay(date: 'היום', items: [
      WorkLogItem(
        worker: '—',
        task: 'אין עדיין משימות שאושרו היום',
        status: 'none',
      ),
    ]);
  }
  return WorkLogDay(
    date: 'היום',
    items: [
      for (final t in done)
        WorkLogItem(
          worker: kWorkers[t.worker].replaceAll(' (עובד)', ''),
          task: t.name,
          status: 'done',
        ),
    ],
  );
}

/// The full work log — today (live) + [kWorkLog] history (proto :8161).
final workLogProvider = Provider<List<WorkLogDay>>((ref) {
  final tasks = ref.watch(tasksProvider);
  return [todayWorkLog(tasks), ...kWorkLog];
});
