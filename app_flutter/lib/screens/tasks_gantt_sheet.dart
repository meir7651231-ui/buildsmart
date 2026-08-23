// 📊 TASKS → GANTT SHEET (Wave G2b) — the read-only TIMELINE VIEW over the live
// `tasksProvider`, the UI half of the G2a pure layout (`logic/tasks_gantt.dart`).
// The user's decision: "gantt integrated into the tasks engine" — so this sheet
// renders the §6 tasks straight onto a whole-day timeline, reachable by BOTH the
// contractor (tasks_screen `_managerView`) and the worker (worker_app_screen
// `_TasksTab`). READ-ONLY: it observes; the contractor SETS a task's start date
// from the authoring sheet (`_TaskAuthorSheet`), not here.
//
// HONEST by construction (אין-המצאות, R6/R8 — NEVER an invented date): only a
// task with a real [TaskItem.scheduledStart] gets a bar, and the date shown on
// each row IS that task's actual anchor (recovered as `earliest + startDay`,
// where `earliest` is computed here from the same tasks the layout used — never
// a fabricated date). A task with no anchor is listed off-timeline in the
// UNSCHEDULED section, with the honest note that the contractor can schedule it.
//
// STRUCTURE mirrors `contractor_attendance_sheet.dart` (grab-handle + header row
// with a ✕ close + subtitle, RTL DraggableScrollableSheet/ListView). The bar
// math replicates the simple proportional bar of `_SiteGantt`/`_GanttRow`
// (site_hub_screen.dart) — those are private, so the math is replicated, not
// imported: an RTL track where the colored segment is offset from the RIGHT by
// `startDay/spanDays` of the width and spans `lenDays/spanDays`, with a done%
// sub-fill from the start (right) edge.

import 'package:buildsmart/data/persona_data.dart' show kTaskStatusLabel;
import 'package:buildsmart/logic/tasks_gantt.dart';
import 'package:buildsmart/screens/worker_profile_screen.dart'
    show workerIndexForSession;
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Open the read-only tasks-gantt timeline — the wire target for both the
/// contractor's '📊 גאנט משימות' action (tasks_screen) and the worker's
/// (worker_app_screen). Same sheet for both: it only ever observes the live
/// `tasksProvider`.
Future<void> showTasksGanttSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _TasksGanttSheet(),
  );
}

class _TasksGanttSheet extends ConsumerWidget {
  const _TasksGanttSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The LIVE §6 tasks, SCOPED to the viewer before the pure G2a layout — so the
    // timeline never renders every employer's/worker's tasks on one axis. A
    // WORKER board sees ONLY their own tasks (the same `t.worker == <self index>`
    // filter the worker board's `_bucket`/`mine` uses, via workerIndexForSession);
    // the contractor / no-board-session sees THIS employer's tasks (the same
    // `employerId == kDemoContractorId` scope the other contractor sheets use).
    // SERVER-SWAP: kDemoContractorId is the single-device demo employer id; the
    // real contractor uid when the backend lands (as the other contractor sheets).
    final session = ref.watch(boardAuthProvider);
    final all = ref.watch(tasksProvider);
    final tasks = (session != null && session.role == BoardRole.worker)
        ? [
            for (final t in all)
              if (workerOwnsTask(
                  t, workerIndexForSession(session), session.uid))
                t
          ]
        : [
            for (final t in all)
              // DEMO-SEED: unstamped seeds belong to the demo contractor too.
              if (t.employerId == kDemoContractorId || t.employerId.isEmpty) t
          ];
    final layout = buildTasksGantt(tasks);

    // The earliest scheduled DATE (time-of-day dropped) — day 0 of the timeline.
    // Computed from the SAME tasks the layout placed, so turning a bar's
    // `startDay` back into a calendar date (`earliest + startDay`) yields the
    // task's REAL anchor, never an invented one. Null when nothing is scheduled.
    final scheduled = [for (final t in tasks) if (t.scheduledStart != null) t];
    final earliest = scheduled.isEmpty
        ? null
        : scheduled
            .map((t) => DateTime(t.scheduledStart!.year,
                t.scheduledStart!.month, t.scheduledStart!.day))
            .reduce((a, b) => a.isBefore(b) ? a : b);

    final empty = layout.bars.isEmpty && layout.unscheduled.isEmpty;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scroll) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(BsTokens.radiusCard)),
          ),
          child: ListView(
            controller: scroll,
            padding: const EdgeInsets.all(BsTokens.space4),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: BsTokens.space3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDDDDD),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header row — title + a ✕ close (≥48dp tap target).
              Row(
                children: [
                  const Expanded(
                    child: CfgText(
                      'tasks_gantt_sheet.header',
                      '📊 גאנט משימות',
                      style: TextStyle(
                        color: BsTokens.inkLight,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    key: const ValueKey('tasks-gantt-close'),
                    iconSize: 24,
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    tooltip: 'סגור',
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close, color: BsTokens.mutedLight),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              const CfgText(
                'tasks_gantt_sheet.subtitle',
                'לוח-הזמנים של המשימות לפי תאריך-התחלה מתוזמן (לצפייה בלבד)',
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
              ),
              const SizedBox(height: BsTokens.space3),

              // Whole-board empty state — no scheduled bars AND no unscheduled.
              if (empty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: BsTokens.space5),
                  child: CfgText(
                    'tasks_gantt_sheet.empty',
                    'אין משימות',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: BsTokens.inkLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),

              // ══ TIMELINE — one proportional bar per scheduled task ══
              if (layout.bars.isNotEmpty) ...[
                const CfgText(
                  'tasks_gantt_sheet.timeline',
                  '📊 לוח-זמנים (גאנט)',
                  style: TextStyle(
                    color: BsTokens.inkLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: BsTokens.space3),
                for (final bar in layout.bars) ...[
                  _GanttBarRow(
                    bar: bar,
                    spanDays: layout.spanDays,
                    // earliest is non-null here (bars non-empty ⇒ ≥1 scheduled).
                    start: earliest!.add(Duration(days: bar.startDay)),
                  ),
                  const SizedBox(height: BsTokens.space3),
                ],
              ],

              // ══ UNSCHEDULED — tasks with no anchor, listed honestly off-axis ══
              if (layout.unscheduled.isNotEmpty) ...[
                if (layout.bars.isNotEmpty) const Divider(height: 32),
                Text(
                  '🗓️ ללא תאריך מתוזמן (${layout.unscheduled.length})',
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 2),
                const CfgText(
                  'tasks_gantt_sheet.unscheduled_note',
                  'משימות אלו לא ממוקמות על הציר — הקבלן יכול לשבץ להן תאריך התחלה.',
                  style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
                ),
                const SizedBox(height: BsTokens.space3),
                for (final t in layout.unscheduled) ...[
                  _UnscheduledRow(task: t),
                  const SizedBox(height: BsTokens.space2),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// One timeline row — the task name + its REAL start date (dd.MM) + a horizontal
/// proportional bar. The bar is a full-width RTL track; the colored segment is
/// offset from the RIGHT edge by `startDay/spanDays` and spans `lenDays/spanDays`
/// of the width (replicating `_GanttRow`'s simple math). A darker done% sub-fill
/// grows from the start (right) edge, with an "N%" label. Single-day-only board
/// (`spanDays == 0`) → the bar fills its whole cell (guarded fractions).
class _GanttBarRow extends StatelessWidget {
  const _GanttBarRow({
    required this.bar,
    required this.spanDays,
    required this.start,
  });

  final GanttBar bar;
  final int spanDays;

  /// The task's REAL scheduled start (recovered as earliest + startDay) — shown
  /// dd.MM. Never invented (earliest comes from the live tasks).
  final DateTime start;

  @override
  Widget build(BuildContext context) {
    // Guard spanDays == 0 (a single same-day task): the bar fills its own cell
    // rather than dividing by zero.
    final leftFrac = spanDays == 0 ? 0.0 : bar.startDay / spanDays;
    final widFrac = spanDays == 0 ? 1.0 : bar.lenDays / spanDays;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                bar.name,
                style: const TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
            // Real start date (dd.MM) + duration in days — honest, never faked.
            Text(
              '${_fmtDayMonth(start)} · ${bar.lenDays} ימ׳',
              style: const TextStyle(
                color: BsTokens.mutedLight,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // The proportional track — RTL: the bar is offset from the RIGHT edge.
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final barW = w * widFrac;
            final rightOffset = w * leftFrac;
            return Container(
              height: 24,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: rightOffset,
                    top: 0,
                    bottom: 0,
                    width: barW,
                    child: Container(
                      decoration: BoxDecoration(
                        // brand at .22 opacity — the bar track (matches the
                        // _SiteGantt rgba(brand,.22) tint, on the orange brand).
                        color: BsTokens.brand.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // done% sub-fill — fills from the start (right) edge.
                          FractionallySizedBox(
                            alignment: AlignmentDirectional.centerStart,
                            widthFactor: bar.donePercent / 100,
                            heightFactor: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: BsTokens.brand,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                          // "N%" label pinned near the start (right) edge.
                          Positioned(
                            right: 6,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: Text(
                                '${bar.donePercent}%',
                                style: const TextStyle(
                                  color: BsTokens.inkLight,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

/// One UNSCHEDULED row — the task name + its verbatim status label
/// ([kTaskStatusLabel]). No date (honest: the task has no anchor).
class _UnscheduledRow extends StatelessWidget {
  const _UnscheduledRow({required this.task});

  final TaskItem task;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              task.name,
              style: const TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            kTaskStatusLabel[task.status] ?? task.status,
            style: const TextStyle(
              color: BsTokens.mutedLight,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// `dd.MM` zero-padded calendar label — a small local formatter (no dart:intl in
/// this codebase; mirrors the hand-formatting in the attendance/forms sheets).
/// The date is always a task's real [TaskItem.scheduledStart] — never invented.
String _fmtDayMonth(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.'
    '${d.month.toString().padLeft(2, '0')}';
