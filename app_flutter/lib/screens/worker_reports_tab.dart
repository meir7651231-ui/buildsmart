// 🦺 דוחות v2 (board W, cluster #85ז) — the worker board's reports tab,
// extracted from `worker_app_screen.dart`'s old `_ReportsTab` and rebuilt:
//   ① סיכום שבועי — bar chart of approved tasks per weekday (plain Containers).
//   ② אחוז אישור-ראשון — approved-without-rejection / total submitted.
//   ③ זמן לכל משימה — from the bs.task-clock.v1 side-map (startedAt/completedAt).
//   ④ מטבעות + רצף — live [rewardsProvider] coins + an HONEST streak computed
//      from the task-clock stamps (consecutive calendar days ending today with
//      a startedAt/completedAt for this worker; no stamps at all → '—').
//   ⑤ פירוט לפי אזור עבודה — honest grouping by the task NAME's ' — ' suffix
//      (the engine has no site/project field — see [TaskItem]).
//   ⑥ היסטוריית הגשות עם תמונות — proof-photo thumbnail per submission row
//      (data-URL or uploaded https URL → Image · 'demo' → honest placeholder).
//   ⑦ דחיות + סיבה — rejected tasks with the manager's reason when one was
//      stored (bs.task-reject-note.v1 side-map), 'לא צורפה סיבה' otherwise.
//   ⑧ שלח דוח יומי לקבלן — composes the live status counts and posts them as a
//      REAL chat message into the worker↔contractor thread (sys_chat engine).
//
// אין המצאות: every number is derived live from [tasksProvider] /
// [rewardsProvider] / the side-maps. Where the engine has no data (timestamps
// before the task-clock landed, a rejection without a stored reason), the tab
// says so honestly instead of inventing.
//
// SIDE-MAP CONTRACTS (read-only here — the writers live with the engines):
//   bs.task-clock.v1        {taskId: {startedAt: iso, completedAt: iso}}
//   bs.task-reject-note.v1  {taskId: reason}
//   bs.task-rejections.v1   [taskId, ...] — ever-seen-rejected log; WRITTEN by
//                           the board shell (worker_app_screen) because the
//                           engine keeps only the CURRENT status.
// FIXER NOTE: if the ENG cluster put startedAt/completedAt (or a manager
// reject-note) directly on [TaskItem] instead of the side-maps, swap the
// providers below for the fields — the widgets only consume the maps.

import 'dart:convert';

import 'package:buildsmart/data/persona_data.dart';
import 'package:buildsmart/logic/calendar_days.dart';
import 'package:buildsmart/screens/worker_report_drilldowns.dart';
import 'package:buildsmart/state/rewards_state.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:buildsmart/widgets/photo_viewer.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── side-map keys ───────────────────────────────────────────────────────────

/// `{taskId: {startedAt, completedAt}}` — written by the task engine when a
/// task turns `active` / is approved (the #85 ENG cluster).
const String kTaskClockKey = 'bs.task-clock.v1';

/// `{taskId: reason}` — the manager's rejection reason, written on the manager
/// side when a reject carries a note.
const String kTaskRejectNoteKey = 'bs.task-reject-note.v1';

/// `[taskId, ...]` — every task EVER seen in `rejected` status (the engine
/// stores only the current status, so first-pass needs this log).
const String kTaskRejectionsKey = 'bs.task-rejections.v1';

// ─── task clock (read-only view of bs.task-clock.v1) ─────────────────────────

/// One task's clock entry. Both stamps optional — a task started before the
/// clock landed has neither, an active task has only [startedAt].
class TaskClockEntry {
  const TaskClockEntry({this.startedAt, this.completedAt});

  final DateTime? startedAt;
  final DateTime? completedAt;

  /// Wall-clock time from start to approval — null unless both stamps exist
  /// and are ordered (corrupt/clock-skewed pairs are not shown).
  Duration? get duration =>
      startedAt != null &&
              completedAt != null &&
              completedAt!.isAfter(startedAt!)
          ? completedAt!.difference(startedAt!)
          : null;
}

/// The bs.task-clock.v1 side-map, re-read whenever the task list mutates
/// (a status move is exactly when the writer updates the clock).
final taskClockProvider = FutureProvider<Map<int, TaskClockEntry>>((ref) async {
  ref.watch(tasksProvider); // any task mutation → re-read the side-map
  try {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kTaskClockKey);
    if (raw == null || raw.isEmpty) return const {};
    final m = jsonDecode(raw) as Map<String, dynamic>;
    final out = <int, TaskClockEntry>{};
    m.forEach((k, v) {
      final id = int.tryParse(k);
      if (id == null || v is! Map) return;
      final s = DateTime.tryParse('${v['startedAt']}');
      final c = DateTime.tryParse('${v['completedAt']}');
      if (s == null && c == null) return;
      out[id] = TaskClockEntry(startedAt: s, completedAt: c);
    });
    return out;
  } on Object catch (_) {
    return const {}; // corrupt payload — honest "no measurements" state
  }
});

/// The bs.task-reject-note.v1 side-map (manager rejection reasons), re-read on
/// any task mutation — same pattern as [taskClockProvider].
final taskRejectNotesProvider = FutureProvider<Map<int, String>>((ref) async {
  ref.watch(tasksProvider);
  try {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kTaskRejectNoteKey);
    if (raw == null || raw.isEmpty) return const {};
    final m = jsonDecode(raw) as Map<String, dynamic>;
    final out = <int, String>{};
    m.forEach((k, v) {
      final id = int.tryParse(k);
      if (id == null || v is! String || v.trim().isEmpty) return;
      out[id] = v.trim();
    });
    return out;
  } on Object catch (_) {
    return const {};
  }
});

// ─── ever-rejected log (bs.task-rejections.v1) ───────────────────────────────

/// Persisted set of task ids EVER seen `rejected`. The engine keeps only the
/// CURRENT status, so a rejected-then-resubmitted-then-approved task looks
/// "clean" — this log is what makes אחוז אישור-ראשון a real computation.
/// Recorded by the worker board shell on every rebuild (see
/// `worker_app_screen.dart`); persisted with the board_auth `_userTouched`
/// idiom so a late `_load()` never clobbers a fresh record.
class TaskRejectionLog extends StateNotifier<Set<int>> {
  TaskRejectionLog({this.persist = true}) : super(const {}) {
    if (persist) _load();
  }

  /// When false (tests), skip SharedPreferences entirely.
  final bool persist;

  /// One-shot guard (the board_auth idiom) — set ONLY by [resetLog]: a
  /// `recordAll` that lands before prefs resolve is safe because `_load`
  /// MERGES (union), but a reset must not be clobbered by a late load.
  bool _userTouched = false;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(kTaskRejectionsKey);
      if (raw == null || raw.isEmpty || _userTouched) return;
      final ids =
          (jsonDecode(raw) as List)
              .whereType<num>()
              .map((n) => n.toInt())
              .toSet();
      if (ids.isEmpty || _userTouched) return;
      // MERGE (not replace) — ids recorded before prefs resolved are kept.
      state = {...state, ...ids};
    } on Object catch (_) {
      // corrupt payload — keep whatever was recorded this session
    }
  }

  Future<void> _persist() async {
    if (!persist) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        kTaskRejectionsKey,
        jsonEncode(state.toList()..sort()),
      );
    } on Object catch (_) {}
  }

  /// Remember [ids] as ever-rejected. No-op (no rebuild, no write) when every
  /// id is already known. Safe against the load race without the guard — a
  /// late `_load` only ADDS persisted ids, never drops recorded ones.
  void recordAll(Iterable<int> ids) {
    final add = ids.where((id) => !state.contains(id)).toList();
    if (add.isEmpty) return;
    state = {...state, ...add};
    _persist();
  }

  /// Forget everything (tests / a future "demo reset").
  void resetLog() {
    _userTouched = true;
    state = const {};
    _persist();
  }
}

final taskRejectionLogProvider =
    StateNotifierProvider<TaskRejectionLog, Set<int>>(
      (_) => TaskRejectionLog(),
    );

// ─── helpers ─────────────────────────────────────────────────────────────────

/// Work-area of a task, derived HONESTLY from its name: the suffix after the
/// ' — ' separator (e.g. 'התקנת קו מים חם — חדר רחצה' → 'חדר רחצה'). The task
/// engine has no site/project field, so this is the only grouping that exists;
/// names without the separator group under 'כללי'.
String taskWorkArea(String name) {
  final i = name.indexOf(' — ');
  if (i < 0) return 'כללי';
  final area = name.substring(i + 3).trim();
  return area.isEmpty ? 'כללי' : area;
}

/// Hebrew week-day letters, Sunday-first (index = weekday % 7).
const List<String> _kDayLetters = ['א׳', 'ב׳', 'ג׳', 'ד׳', 'ה׳', 'ו׳', 'ש׳'];

String _fmtDuration(Duration d) {
  if (d.inMinutes < 1) return 'פחות מדקה';
  if (d.inHours < 1) return '${d.inMinutes} דק׳';
  if (d.inDays < 1) {
    final m = d.inMinutes % 60;
    return m == 0 ? '${d.inHours} שע׳' : '${d.inHours} שע׳ $m דק׳';
  }
  final h = d.inHours % 24;
  return h == 0 ? '${d.inDays} ימים' : '${d.inDays} ימים $h שע׳';
}

String _hhmm(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

// ─── the tab ─────────────────────────────────────────────────────────────────

/// Tab 3 — דוחות v2 (#85ז): everything derived LIVE for the logged worker only
/// (#66 — a worker sees only their own tasks everywhere).
class WorkerReportsTab extends ConsumerWidget {
  const WorkerReportsTab({required this.worker, super.key});

  /// Index into [kWorkers] — the logged worker (see `workerIndexForSession`).
  final int worker;

  /// The seed id of the worker↔contractor thread ([kWorkerChatThreads],
  /// `sys_chat.dart`) the daily report is posted into.
  static const String kContractorThreadId = 'th-worker-contractor';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mine =
        ref.watch(tasksProvider).where((t) => t.worker == worker).toList();
    final clock =
        ref.watch(taskClockProvider).asData?.value ??
        const <int, TaskClockEntry>{};
    final rejectNotes =
        ref.watch(taskRejectNotesProvider).asData?.value ??
        const <int, String>{};
    final everRejected = ref.watch(taskRejectionLogProvider);
    final rewards = ref.watch(rewardsProvider);

    final doneTasks = mine.where((t) => t.status == 'done').toList();
    final submitted =
        mine
            .where(
              (t) =>
                  t.status == 'review' ||
                  t.status == 'done' ||
                  t.status == 'rejected',
            )
            .toList();
    final rejectedTasks = mine.where((t) => t.status == 'rejected').toList();

    // ① weekly buckets — Sunday-first; only completions stamped THIS week land
    // on a bar. Approved tasks without a completedAt stamp (done before the
    // task-clock landed) go to the honest 'ללא תאריך' bucket.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = startOfWeekSunday(today);
    final perDay = List<int>.filled(7, 0);
    var noDate = 0;
    for (final t in doneTasks) {
      final c = clock[t.id]?.completedAt;
      if (c == null) {
        noDate++;
        continue;
      }
      final dayIdx = daysBetweenDst(weekStart, c);
      if (dayIdx >= 0 && dayIdx < 7) perDay[dayIdx]++;
      // a completion stamped in a previous week is simply outside this chart.
    }
    final weekTotal = perDay.fold<int>(0, (a, b) => a + b);

    // ④ honest streak (#10) — consecutive calendar days ENDING TODAY on which
    // this worker's task clock has a stamp (startedAt/completedAt on the
    // engine's own TaskItem fields). No stamps at all → '—' (no invented
    // streak; the contractor hub keeps its seed honestly labeled as demo).
    final activityDays = <DateTime>{};
    for (final t in mine) {
      for (final ts in [t.startedAt, t.completedAt]) {
        if (ts != null) activityDays.add(DateTime(ts.year, ts.month, ts.day));
      }
    }
    var streak = 0;
    while (activityDays.contains(
      DateTime(today.year, today.month, today.day - streak),
    )) {
      streak++;
    }
    final streakLabel = activityDays.isEmpty ? '—' : '$streak ימים';

    // ② first-pass approval — approved-without-ever-being-rejected / submitted.
    final firstPass =
        doneTasks.where((t) => !everRejected.contains(t.id)).length;
    final firstPassLabel =
        submitted.isEmpty
            ? '—'
            : '${(firstPass * 100 / submitted.length).round()}%';

    // ③ durations — only pairs the clock actually measured.
    final timed = [
      for (final t in mine)
        if (clock[t.id]?.duration != null) t,
    ];
    final running = [
      for (final t in mine)
        if (t.status == 'active' &&
            clock[t.id]?.startedAt != null &&
            clock[t.id]?.completedAt == null)
          t,
    ];

    // ⑤ per-area grouping (honest — from the task name; no site field exists).
    final areas = <String, List<TaskItem>>{};
    for (final t in mine) {
      areas.putIfAbsent(taskWorkArea(t.name), () => []).add(t);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        BsTokens.space4,
        BsTokens.space4,
        BsTokens.space4,
        BsTokens.space5,
      ),
      children: [
        const Text(
          '📊 דוחות',
          style: TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'נתונים חיים מהמשימות של ${workerShortName(worker)} — ללא המצאות',
          style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13),
        ),
        const SizedBox(height: BsTokens.space4),

        // ── ② + ④ KPI row: first-pass % · BuildCoins · streak ──
        // #109 — each box dives to a REAL drill-down of the data behind it.
        Row(
          children: [
            HelpTarget(
              title: 'אישור ראשון',
              body:
                  'אחוז ההגשות שאושרו בלי דחייה מתוך כלל ההגשות. לחיצה פותחת פירוט מלא של הנתון.',
              child: _KpiBox(
                value: firstPassLabel,
                label: 'אישור-ראשון 🎯',
                onTap:
                    () => showFirstPassDrilldown(context, ref, worker: worker),
              ),
            ),
            // F-33: מאזן המטבעות הוא overlay אחד לכל המכשיר (bs.rewards.v1,
            // ללא username) — תווית כנה, לא מספר שמתחזה ל-per-עובד.
            HelpTarget(
              title: 'BuildCoins',
              body:
                  'מאזן מועדון BuildSmart המשותף לכל התפקידים במכשיר (אינו נצבר לעובד בנפרד). לחיצה פותחת פירוט.',
              child: _KpiBox(
                value: '${rewards.coins}',
                label: 'BuildCoins (מועדון משותף) 🪙',
                onTap: () => showCoinsDrilldown(context, ref),
              ),
            ),
            HelpTarget(
              title: 'רצף פעילות',
              body:
                  'מספר הימים הרצופים עם פעילות לפי שעון-המשימות. לחיצה פותחת פירוט הרצף.',
              child: _KpiBox(
                value: streakLabel,
                label: 'רצף פעילות 🔥',
                onTap: () => showStreakDrilldown(context, ref, worker: worker),
              ),
            ),
          ],
        ),
        const SizedBox(height: BsTokens.space2),
        Text(
          submitted.isEmpty
              ? 'אישור-ראשון = הגשות שאושרו בלי דחייה מתוך כלל ההגשות — עדיין אין הגשות. מטבעות — מאזן מועדון BuildSmart המשותף לכל התפקידים במכשיר (אינו נצבר לעובד בנפרד); הרצף נמדד משעון המשימות (ימים רצופים עם פעילות).'
              : 'אישור-ראשון: $firstPass מתוך ${submitted.length} הגשות אושרו בלי דחייה. מטבעות — מאזן מועדון BuildSmart המשותף לכל התפקידים במכשיר (אינו נצבר לעובד בנפרד); הרצף נמדד משעון המשימות (ימים רצופים עם פעילות).',
          style: const TextStyle(color: BsTokens.mutedLight, fontSize: 11.5),
        ),
        const SizedBox(height: BsTokens.space4),

        // ── ① weekly summary bar chart ──
        _Card(
          title: '📅 סיכום שבועי — משימות שאושרו',
          children: [
            if (weekTotal == 0 && noDate == 0)
              Text(
                doneTasks.isEmpty
                    ? 'עוד אין משימות שאושרו — משימה שתאושר תופיע כאן.'
                    : 'אין משימות שאושרו השבוע.',
                style: const TextStyle(
                  color: BsTokens.mutedLight,
                  fontSize: 13,
                ),
              )
            else ...[
              _WeekBars(
                counts: perDay,
                todayIndex: today.weekday % 7,
                // #109 — tapping a bar opens that day's clocked tasks.
                onTapDay:
                    (i) => showWeekDayDrilldown(
                      context,
                      ref,
                      worker: worker,
                      day: weekStart.add(Duration(days: i)),
                    ),
              ),
              if (noDate > 0) ...[
                const SizedBox(height: BsTokens.space2),
                Text(
                  // Honest bucket — approved before the task-clock existed.
                  '🗓️ ללא תאריך: $noDate ${noDate == 1 ? 'משימה שאושרה' : 'משימות שאושרו'} בלי חותמת-זמן (לפני הפעלת שעון המשימות)',
                  style: const TextStyle(
                    color: BsTokens.mutedLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ],
        ),
        const SizedBox(height: BsTokens.space3),

        // ── ③ time per task ──
        _Card(
          title: '⏱️ זמן לכל משימה',
          children: [
            if (timed.isEmpty && running.isEmpty)
              const Text(
                'אין עדיין מדידות זמן — הזמן נמדד אוטומטית מרגע תחילת משימה ועד אישורה.',
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
              )
            else ...[
              // #109 — each timed row dives to that task's full time detail.
              for (final t in timed)
                HelpTarget(
                  title: 'זמן משימה',
                  body:
                      'מציג את משך-העבודה שנמדד למשימה. לחיצה פותחת פירוט זמן מלא של המשימה.',
                  child: _KvRow(
                    label: t.name,
                    value: _fmtDuration(clock[t.id]!.duration!),
                    onTap: () => showTaskTimeDrilldown(context, ref, task: t),
                  ),
                ),
              for (final t in running)
                HelpTarget(
                  title: 'זמן משימה',
                  body:
                      'מציג את משך-העבודה שנמדד למשימה. לחיצה פותחת פירוט זמן מלא של המשימה.',
                  child: _KvRow(
                    label: t.name,
                    value: '🔨 בביצוע מאז ${_hhmm(clock[t.id]!.startedAt!)}',
                    onTap: () => showTaskTimeDrilldown(context, ref, task: t),
                  ),
                ),
            ],
          ],
        ),
        const SizedBox(height: BsTokens.space3),

        // ── ⑤ per-work-area breakdown ──
        _Card(
          title: '📍 פירוט לפי אזור עבודה',
          children: [
            // #109 — each area row dives to the tasks grouped under it.
            for (final e in areas.entries)
              HelpTarget(
                title: 'אזור עבודה',
                body:
                    'מסכם כמה משימות אושרו בכל אזור (הנגזר משם המשימה). לחיצה פותחת את המשימות באזור.',
                child: _KvRow(
                  label: e.key,
                  value:
                      '${e.value.where((t) => t.status == 'done').length}/${e.value.length} אושרו',
                  onTap:
                      () => showAreaDrilldown(
                        context,
                        ref,
                        worker: worker,
                        area: e.key,
                      ),
                ),
              ),
            const SizedBox(height: BsTokens.space1),
            const Text(
              // Honest: derived from the task name — the engine has no site
              // field; real project-site binding יחובר עם חיבור השרת.
              'האזור נגזר משם המשימה (אין שדה אתר במנוע המשימות). שיוך לאתרי פרויקט אמיתיים יחובר עם חיבור השרת.',
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 11.5),
            ),
          ],
        ),
        const SizedBox(height: BsTokens.space3),

        // ── ⑥ submission history with proof-photo thumbnails ──
        _Card(
          title: '📋 היסטוריית הגשות (${submitted.length})',
          children: [
            if (submitted.isEmpty)
              const Text(
                'עוד לא הגשת משימות לאישור — ההגשות שלך יופיעו כאן.',
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
              )
            else
              for (final t in submitted)
                _HistoryRow(
                  task: t,
                  duration: clock[t.id]?.duration,
                  // #109 — the row BODY opens the submission detail; the proof
                  // thumbnail keeps its own full-screen viewer tap.
                  onTap:
                      () => showSubmissionDrilldown(
                        context,
                        task: t,
                        duration: clock[t.id]?.duration,
                      ),
                ),
          ],
        ),
        const SizedBox(height: BsTokens.space3),

        // ── ⑦ rejections + manager reason ──
        _Card(
          title: '↩️ דחיות לתיקון (${rejectedTasks.length})',
          children: [
            if (rejectedTasks.isEmpty)
              const Text(
                'אין משימות שנדחו לתיקון.',
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
              )
            else
              // #109 — each rejection row dives to the manager's reason + task.
              for (final t in rejectedTasks)
                HelpTarget(
                  title: 'סיבת דחייה',
                  body:
                      'לחיצה פותחת את סיבת הדחייה של המנהל ואת פרטי המשימה לתיקון.',
                  child: Semantics(
                    button: true,
                    label: '${t.name} — הצג סיבת דחייה',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap:
                          () => showRejectionDrilldown(context, ref, task: t),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: 48,
                        ), // ≥48dp target
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: ExcludeSemantics(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.name,
                                        style: const TextStyle(
                                          color: BsTokens.inkLight,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        rejectNotes[t.id] != null
                                            ? 'סיבת המנהל: "${rejectNotes[t.id]}"'
                                            // Honest — rejected without a reason
                                            // (or before reasons were stored).
                                            : 'המנהל לא צירף סיבה לדחייה.',
                                        style: TextStyle(
                                          color:
                                              rejectNotes[t.id] != null
                                                  ? BsTokens.inkLight
                                                  : BsTokens.mutedLight,
                                          fontSize: 12.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_left,
                                  size: 18,
                                  color: BsTokens.mutedLight,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
          ],
        ),
        const SizedBox(height: BsTokens.space4),

        // ── ⑧ send daily report to the contractor — a REAL chat message ──
        HelpTarget(
          title: 'שלח דוח יומי לקבלן',
          body:
              "שולח לקבלן בצ'אט סיכום אמיתי של מצבי-המשימות הנוכחי שלך — בלי המצאות.",
          child: Semantics(
            button: true,
            label: 'שלח דוח יומי לקבלן',
            child: Material(
              color: BsTokens.brand,
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
              child: InkWell(
                key: const ValueKey('send-daily-report'),
                borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                onTap: () => _sendDailyReport(context, ref),
                child: Container(
                  height: 48, // ≥48dp target
                  alignment: Alignment.center,
                  child: Text(
                    '💬 שלח דוח יומי לקבלן',
                    style: TextStyle(
                      color: bsOnAccent(context),
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: BsTokens.space2),
        const Text(
          'הדוח נשלח כהודעה אמיתית לשיחת הקבלן (טאב שיחות) — סיכום הסטטוסים הנוכחי, בלי המצאות.',
          textAlign: TextAlign.center,
          style: TextStyle(color: BsTokens.mutedLight, fontSize: 11.5),
        ),
      ],
    );
  }

  /// Compose the live status counts into Hebrew text and post it into the
  /// worker↔contractor thread ([kContractorThreadId]) via the shared chat
  /// engine. The contractor reads it in his שיחות tab (עדכונים): that list
  /// admits worker-audience threads he participates in (`_visibleToAudience`,
  /// chats_screen.dart), where the thread renders as 'עובד — רן'.
  void _sendDailyReport(BuildContext context, WidgetRef ref) {
    final mine =
        ref.read(tasksProvider).where((t) => t.worker == worker).toList();
    int count(String s) => mine.where((t) => t.status == s).length;
    final done = count('done');
    final review = count('review');
    final rejected = count('rejected');
    final active = count('active');
    final queued = count('pending');

    final now = DateTime.now();
    final text =
        'דוח יומי — ${workerShortName(worker)} (${now.day}.${now.month}):\n'
        '✅ אושרו: $done\n'
        '📸 הוגשו וממתינות לאישור: $review\n'
        '↩️ נדחו לתיקון: $rejected\n'
        '🔨 בביצוע: $active\n'
        '⏳ בתור: $queued';

    // Guard: send() is a silent no-op on an unknown thread — never toast a
    // success that did not happen (אין חצי-עבודה).
    final exists = ref
        .read(chatEngineProvider)
        .any((t) => t.id == kContractorThreadId);
    if (!exists) {
      showToast(context, 'שיחת הקבלן לא נמצאה — הדוח לא נשלח');
      return;
    }
    ref
        .read(chatEngineProvider.notifier)
        .send(kContractorThreadId, BsRole.worker, text);
    showToast(context, '💬 הדוח נשלח לקבלן — מופיע בטאב שיחות');
  }
}

// ─── building blocks ─────────────────────────────────────────────────────────

/// White stat box (the courier reports `_RStat` idiom — board style). When
/// [onTap] is set (#109) the whole box becomes a ≥48dp button that opens its
/// drill-down; the inner value/label are excluded from semantics so the box's
/// own button label is announced once.
class _KpiBox extends StatelessWidget {
  const _KpiBox({required this.value, required this.label, this.onTap});

  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final inner = Padding(
      padding: const EdgeInsets.symmetric(vertical: BsTokens.space3),
      child: ExcludeSemantics(
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12),
            ),
          ],
        ),
      ),
    );

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: BsTokens.cardLight,
          borderRadius: BorderRadius.circular(BsTokens.radiusCard),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child:
            onTap == null
                ? inner
                : Semantics(
                  button: true,
                  label: '$label — הצג פירוט',
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(BsTokens.radiusCard),
                      onTap: onTap,
                      child: inner,
                    ),
                  ),
                ),
      ),
    );
  }
}

/// White card with a bold title — the worker board's card style.
class _Card extends StatelessWidget {
  const _Card({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BsTokens.space4),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: BsTokens.space3),
          ...children,
        ],
      ),
    );
  }
}

/// Label-value row (task name ← → metric), RTL-safe. When [onTap] is set (#109)
/// the row becomes a ≥48dp button (with a trailing chevron hint) that opens its
/// drill-down; the inner texts are excluded so the row announces one button.
class _KvRow extends StatelessWidget {
  const _KvRow({required this.label, required this.value, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: BsTokens.inkLight, fontSize: 13.5),
          ),
        ),
        const SizedBox(width: BsTokens.space2),
        Text(
          value,
          style: const TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        if (onTap != null) ...[
          const SizedBox(width: 2),
          const Icon(Icons.chevron_left, size: 18, color: BsTokens.mutedLight),
        ],
      ],
    );

    if (onTap == null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: BsTokens.space2),
        child: row,
      );
    }
    return Semantics(
      button: true,
      label: '$label, $value — הצג פירוט',
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48), // ≥48dp target
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ExcludeSemantics(child: row),
          ),
        ),
      ),
    );
  }
}

/// The weekly bar chart — plain Containers, no chart lib. Sunday-first; under
/// the board's RTL Directionality the first child renders on the RIGHT, so
/// ראשון starts at the right edge as a Hebrew calendar reads.
class _WeekBars extends StatelessWidget {
  const _WeekBars({
    required this.counts,
    required this.todayIndex,
    this.onTapDay,
  });

  /// Approved-task count per weekday, index = weekday % 7 (0 = ראשון).
  final List<int> counts;
  final int todayIndex;

  /// #109 — tap a bar (by its weekday index) → that day's clocked tasks.
  final ValueChanged<int>? onTapDay;

  @override
  Widget build(BuildContext context) {
    final maxC = counts.fold<int>(1, (a, b) => b > a ? b : a);
    return SizedBox(
      height: 112,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: _BarColumn(
                index: i,
                count: counts[i],
                maxCount: maxC,
                isToday: i == todayIndex,
                onTap: onTapDay == null ? null : () => onTapDay!(i),
              ),
            ),
        ],
      ),
    );
  }
}

/// One weekday bar — its own tappable column (#109). The full 112dp height is
/// the hit target (well over 48dp); the inner labels are excluded from
/// semantics so the column announces one button.
class _BarColumn extends StatelessWidget {
  const _BarColumn({
    required this.index,
    required this.count,
    required this.maxCount,
    required this.isToday,
    this.onTap,
  });

  final int index;
  final int count;
  final int maxCount;
  final bool isToday;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final column = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (count > 0)
          Text(
            '$count',
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        const SizedBox(height: 2),
        Container(
          width: 18,
          height: 6 + (count / maxCount) * 56,
          decoration: BoxDecoration(
            color: count > 0 ? BsTokens.brand : const Color(0xFFEDEDED),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _kDayLetters[index],
          style: TextStyle(
            color: isToday ? BsTokens.brandDark : BsTokens.mutedLight,
            fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ],
    );
    if (onTap == null) return column;
    return HelpTarget(
      title: 'יום בגרף',
      body: 'לחיצה על עמודת-יום פותחת את רשימת המשימות שאושרו באותו יום.',
      child: Semantics(
        button: true,
        label: 'יום ${_kDayLetters[index]} — $count אושרו, הצג פירוט',
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          // Fill the row's full height so the whole bar slot is the hit
          // target, while the bar itself stays bottom-aligned (chart look).
          child: SizedBox(
            height: double.infinity,
            child: ExcludeSemantics(
              child: Align(alignment: Alignment.bottomCenter, child: column),
            ),
          ),
        ),
      ),
    );
  }
}

/// One submission-history row: proof thumbnail + name + status pill + the
/// worker's note + the measured duration when the clock has one.
class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.task, this.duration, this.onTap});

  final TaskItem task;
  final Duration? duration;

  /// #109 — opens the submission detail when the row body is tapped. The proof
  /// thumbnail keeps its own independent full-screen-viewer tap.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BsTokens.space3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // #11 — a real proof photo (data-URL or uploaded https URL) opens
          // full-size on tap; 'demo'/empty thumbs stay non-interactive
          // (nothing to enlarge).
          if (imageProviderForRef(task.photo) != null)
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap:
                  () => showDialog<void>(
                    context: context,
                    builder:
                        (_) => Dialog(
                          backgroundColor: Colors.black,
                          insetPadding: const EdgeInsets.all(16),
                          child: Stack(
                            children: [
                              InteractiveViewer(
                                child: Center(
                                  child: Image(
                                    image: imageProviderForRef(task.photo)!,
                                    errorBuilder:
                                        (_, __, ___) => const Padding(
                                          padding: EdgeInsets.all(24),
                                          child: Text(
                                            '📷 לא ניתן להציג את התמונה',
                                            style: TextStyle(
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ),
                                  ),
                                ),
                              ),
                              PositionedDirectional(
                                top: 4,
                                start: 4,
                                // ≥48dp close target on the fullscreen viewer.
                                child: IconButton(
                                  tooltip: 'סגור',
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ),
                            ],
                          ),
                        ),
                  ),
              child: _ProofThumb(photo: task.photo),
            )
          else
            _ProofThumb(photo: task.photo),
          const SizedBox(width: BsTokens.space3),
          Expanded(child: _body(context)),
        ],
      ),
    );
  }

  /// The text body (name · status · duration · note). When [onTap] is set it is
  /// wrapped in a ≥48dp button that opens the submission detail (#109); the
  /// inner texts are excluded so the row body announces one button + a 'הצג
  /// פירוט' hint.
  Widget _body(BuildContext context) {
    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                task.name,
                style: const TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.chevron_left,
                size: 18,
                color: BsTokens.mutedLight,
              ),
          ],
        ),
        const SizedBox(height: 2),
        Wrap(
          spacing: BsTokens.space2,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _StatusPill(status: task.status),
            if (duration != null)
              Text(
                '⏱️ ${_fmtDuration(duration!)}',
                style: const TextStyle(
                  color: BsTokens.mutedLight,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        if (task.note.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            '"${task.note}"',
            style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
          ),
        ],
      ],
    );

    if (onTap == null) return column;
    return HelpTarget(
      title: 'פרטי הגשה',
      body: 'לחיצה על שורת ההגשה פותחת את פירוט-ההגשה — מצב, זמן והערה.',
      child: Semantics(
        button: true,
        label: '${task.name} — הצג פרטי הגשה',
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48), // ≥48dp target
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ExcludeSemantics(child: column),
            ),
          ),
        ),
      ),
    );
  }
}

/// Status pill — the verbatim [kTaskStatusLabel] text over an honest
/// status-tinted background.
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      'done' => (const Color(0xFFD7F5DF), const Color(0xFF1F8A4C)),
      'rejected' => (const Color(0xFFFFE4E4), const Color(0xFFB42318)),
      _ => (const Color(0xFFFFF0E3), BsTokens.brandDark), // review
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      ),
      child: Text(
        kTaskStatusLabel[status] ?? status,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 11.5,
        ),
      ),
    );
  }
}

/// The proof-photo thumbnail (48×48):
///   • a real photo ref (a `data:image/...;base64,` data-URL or an uploaded
///     `https://…` URL, resolved through [imageProviderForRef]) → an [Image]
///     thumb, TAPPABLE (#11) → full-screen pinch/zoom viewer
///     ([showFullPhotoRefDialog]).
///   • the legacy `'demo'` marker → honest 📷 placeholder (no real bytes).
///   • null (e.g. a reject cleared the photo) → honest empty placeholder.
class _ProofThumb extends StatelessWidget {
  const _ProofThumb({required this.photo});

  final String? photo;

  @override
  Widget build(BuildContext context) {
    final p = photo;
    final provider = imageProviderForRef(p);
    if (provider != null) {
      return HelpTarget(
        title: 'תמונת הוכחה',
        body: 'לחיצה על תמונת-ההוכחה הזעירה פותחת אותה במסך מלא עם זום.',
        child: Semantics(
          button: true,
          label: 'הצג תמונת הוכחה במסך מלא',
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => showFullPhotoRefDialog(context, p),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image(
                image: provider,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                // A corrupt payload renders the honest placeholder, not a
                // crash.
                errorBuilder:
                    (_, __, ___) => const _ThumbPlaceholder(glyph: '📷'),
              ),
            ),
          ),
        ),
      );
    }
    // 'demo' marker (no real bytes) → 📷 · no photo at all → an empty box.
    return _ThumbPlaceholder(glyph: p == null ? '—' : '📷');
  }
}

class _ThumbPlaceholder extends StatelessWidget {
  const _ThumbPlaceholder({required this.glyph});

  final String glyph;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        glyph,
        style: const TextStyle(fontSize: 18, color: BsTokens.mutedLight),
      ),
    );
  }
}
