// 📅 TASKS → GANTT LAYOUT (Wave G2a, task-engine-integrated) — the PURE,
// VM-safe (no widgets, no Firebase, no Riverpod, no DateTime.now()) layout the
// gantt sheet (G2b) and its tests share. The user's decision: "gantt integrated
// into the tasks engine" — the §6 tasks ARE the schedule, so this maps a
// `List<TaskItem>` straight onto a whole-day timeline. The caller passes the
// tasks; this file invents NOTHING.
//
// HONESTY (אין-המצאות, R6/R8 — NEVER an invented date): a task carries an
// OPTIONAL [TaskItem.scheduledStart]. Only tasks WITH a non-null anchor are
// placed on the timeline ([GanttBar]s); a task with no anchor is NEVER given a
// synthetic date — it is returned verbatim in [TasksGanttLayout.unscheduled]
// (input order preserved) so the gantt can list it honestly as "not scheduled".
//
// WHOLE-DAY OFFSETS: day offsets are computed on the DATE only — every
// [DateTime] is dropped to `DateTime(y, m, d)` before differencing, so a
// time-of-day on the anchor can never push a bar onto the wrong day or make
// `inDays` round oddly across a DST/partial-day boundary. The earliest
// scheduled DATE is day 0; later tasks are non-negative whole-day offsets from
// it.
//
// DETERMINISTIC ORDER: bars are sorted by (startDay, then taskId) — a stable,
// timestamp-free total order, so the same task set always lays out identically
// (no tie-break ambiguity from equal start days).

import 'package:buildsmart/logic/calendar_days.dart';
import 'package:buildsmart/state/tasks_engine.dart';

/// One task placed on the gantt timeline. [startDay] is the whole-day offset
/// from the earliest scheduled task (the earliest → 0); [lenDays] is the task's
/// duration in whole days, floored at 1 (`max(1, task.days)` — a 0-day task
/// still occupies one visible cell); [donePercent] is 0..100 progress (see
/// [buildTasksGantt] for the rule). [status] is carried verbatim from the task
/// so the bar can be coloured by the 5-state machine.
class GanttBar {
  const GanttBar({
    required this.taskId,
    required this.name,
    required this.startDay,
    required this.lenDays,
    required this.donePercent,
    required this.status,
  });

  final int taskId;
  final String name;

  /// Whole-day offset from the earliest scheduled task (earliest → 0, never
  /// negative).
  final int startDay;

  /// Duration in whole days, floored at 1.
  final int lenDays;

  /// Progress 0..100 (see [buildTasksGantt] for the steps-then-status rule).
  final int donePercent;

  /// The task's status (pending·active·review·done·rejected·proposed), verbatim.
  final String status;
}

/// The full gantt layout: the placed [bars] (deterministically ordered), the
/// total [spanDays] the timeline covers, and the [unscheduled] tasks (those with
/// no [TaskItem.scheduledStart], input order preserved — listed off-timeline, no
/// invented date).
class TasksGanttLayout {
  const TasksGanttLayout({
    required this.bars,
    required this.spanDays,
    required this.unscheduled,
  });

  /// Placed bars, sorted by (startDay, taskId).
  final List<GanttBar> bars;

  /// Total whole-day span the timeline covers — `max(startDay + lenDays)` across
  /// [bars], or 0 when nothing is scheduled.
  final int spanDays;

  /// Tasks with no [TaskItem.scheduledStart], in input order — NEVER placed on
  /// the timeline (no fabricated date).
  final List<TaskItem> unscheduled;
}

/// Drop a [DateTime] to its calendar date (midnight), so all offsets are whole
/// days regardless of the anchor's time-of-day.
DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Progress 0..100 for a task. RULE (documented + unit-tested):
///   • if the task has steps → `(doneSteps.length / steps.length * 100).round()`,
///     clamped to 0..100 (the real checklist progress); else
///   • status-based fallback: `done`/`review` → 100, `active` → 50,
///     everything else (`pending`/`rejected`/`proposed`) → 0.
/// Pure — no clock, no now(); a render-time bar fill, not an invented metric.
int _donePercent(TaskItem t) {
  if (t.steps.isNotEmpty) {
    final pct = (t.doneSteps.length / t.steps.length * 100).round();
    return pct < 0 ? 0 : (pct > 100 ? 100 : pct);
  }
  switch (t.status) {
    case 'done':
    case 'review':
      return 100;
    case 'active':
      return 50;
    default: // pending · rejected · proposed
      return 0;
  }
}

/// Lay [tasks] onto a whole-day gantt timeline (PURE — the G2a cross-file
/// contract the G2b sheet + tests share).
///
/// • SPLIT: a task with a non-null [TaskItem.scheduledStart] is SCHEDULED (gets
///   a [GanttBar]); a task with null goes to [TasksGanttLayout.unscheduled] in
///   input order — NEVER given a synthetic date.
/// • EMPTY: no scheduled tasks → `bars` empty, `spanDays` 0, `unscheduled` = all.
/// • OFFSETS: dates only (time-of-day dropped). `earliest` = the minimum
///   scheduled date → day 0; each bar's `startDay` = `date.difference(earliest)
///   .inDays`, floored at 0 (defensive — earliest is the min, so it is already
///   non-negative).
/// • LENGTH: `lenDays` = `max(1, task.days)` — a 0/negative-day task still
///   occupies one visible cell.
/// • PROGRESS: `donePercent` per the steps-then-status rule (see [_donePercent]).
/// • SPAN: `spanDays` = `max(startDay + lenDays)` across bars (0 if none).
/// • ORDER: bars sorted by (startDay, then taskId) — a stable, timestamp-free
///   total order, so the layout is deterministic with no tie ambiguity.
TasksGanttLayout buildTasksGantt(List<TaskItem> tasks) {
  final scheduled = <TaskItem>[];
  final unscheduled = <TaskItem>[];
  for (final t in tasks) {
    if (t.scheduledStart != null) {
      scheduled.add(t);
    } else {
      unscheduled.add(t);
    }
  }

  // No anchored task → nothing on the timeline; everything is unscheduled.
  if (scheduled.isEmpty) {
    return TasksGanttLayout(
      bars: const [],
      spanDays: 0,
      unscheduled: unscheduled,
    );
  }

  // earliest scheduled DATE (time-of-day dropped) = day 0.
  var earliest = _dateOnly(scheduled.first.scheduledStart!);
  for (final t in scheduled) {
    final d = _dateOnly(t.scheduledStart!);
    if (d.isBefore(earliest)) earliest = d;
  }

  final bars = <GanttBar>[
    for (final t in scheduled)
      GanttBar(
        taskId: t.id,
        name: t.name,
        // earliest → 0; floored at 0 defensively (earliest is the min).
        startDay: () {
          // DST-safe whole-day offset (A4): local-midnight differencing
          // truncates across a spring-forward; daysBetweenDst counts UTC dates.
          final off = daysBetweenDst(earliest, t.scheduledStart!);
          return off < 0 ? 0 : off;
        }(),
        lenDays: t.days < 1 ? 1 : t.days,
        donePercent: _donePercent(t),
        status: t.status,
      ),
  ]..sort((a, b) {
      final byStart = a.startDay.compareTo(b.startDay);
      return byStart != 0 ? byStart : a.taskId.compareTo(b.taskId);
    });

  var spanDays = 0;
  for (final b in bars) {
    final end = b.startDay + b.lenDays;
    if (end > spanDays) spanDays = end;
  }

  return TasksGanttLayout(
    bars: bars,
    spanDays: spanDays,
    unscheduled: unscheduled,
  );
}
