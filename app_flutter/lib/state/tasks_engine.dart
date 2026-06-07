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
  });

  final int id;
  final String name;
  final String detail;
  final int worker; // index into kWorkers
  final String status; // pending·active·review·done·rejected
  final int days;
  final List<String> steps;

  /// `'demo'` once the worker attaches a photo, else null (proto `photo`).
  final String? photo;
  final String note;

  TaskItem copyWith({
    String? status,
    Object? photo = _sentinel,
    String? note,
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
        ),
    ];

const String kTasksScreenKey = 'bs.tasks-screen.v1';

class TasksNotifier extends StateNotifier<List<TaskItem>> {
  TasksNotifier({this.persist = true}) : super(_seedTasks()) {
    if (persist) _load();
  }

  final bool persist;
  bool _loaded = false;

  /// Persist a compact `{id: {status, photo, note}}` overlay onto the verbatim
  /// seed — resilient to seed edits (the worker-tasks-engine pattern).
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
            '${t.id}': {'status': t.status, 'photo': t.photo, 'note': t.note},
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

  /// WORKER attaches a photo — `taskUpload` (proto :8147). Sets photo='demo'.
  void attachPhoto(int id) => _patch(id, (t) => t.copyWith(photo: 'demo'));

  /// WORKER "שלח לאישור" — `taskActionClick` (proto :8133-8145): a current task
  /// (`active`/`rejected`) → `review`; the photo defaults to 'demo' if missing;
  /// the worker's [note] is saved. AUTO-ADVANCE: that worker's next `pending`
  /// task becomes `active`. A no-op unless the task is in a worker-owned status.
  void submitForReview(int id, {String? note}) {
    final t = _byId(id);
    if (t == null) return;
    if (t.status != 'active' && t.status != 'rejected') return;
    _patch(id, (x) => x.copyWith(
          status: 'review',
          photo: x.photo ?? 'demo',
          note: note ?? x.note,
        ));
    // auto-advance: promote the same worker's next queued task.
    final next = state
        .where((x) => x.worker == t.worker && x.status == 'pending')
        .toList();
    if (next.isNotEmpty) {
      _patch(next.first.id, (x) => x.copyWith(status: 'active'));
    }
  }

  /// MANAGER approve — `taskApprove` (proto :8149): `review` → `done` (✅ אושר).
  void approve(int id) {
    final t = _byId(id);
    if (t == null || t.status != 'review') return;
    _patch(id, (x) => x.copyWith(status: 'done'));
  }

  /// MANAGER reject — `taskReject` (proto :8150): `review` → `rejected`, clearing
  /// the photo (proto sets `photo=null`) so the worker re-shoots.
  void reject(int id) {
    final t = _byId(id);
    if (t == null || t.status != 'review') return;
    _patch(id, (x) => x.copyWith(status: 'rejected', photo: null));
  }

  void resetToSeed() => state = _seedTasks();
}

final tasksProvider =
    StateNotifierProvider<TasksNotifier, List<TaskItem>>((ref) => TasksNotifier());

/// Tasks awaiting the manager's approval (`review`), in id order — the manager
/// "📸 ממתין לאישור שלך" bucket, derived LIVE off [tasksProvider].
final tasksPendingReviewProvider = Provider<List<TaskItem>>((ref) {
  final tasks = ref.watch(tasksProvider);
  return tasks.where((t) => t.status == 'review').toList()
    ..sort((a, b) => a.id.compareTo(b.id));
});

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
