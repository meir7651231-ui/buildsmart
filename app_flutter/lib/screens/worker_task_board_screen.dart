import 'package:buildsmart/data/persona_data.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/screens/worker_profile_screen.dart'
    show workerIndexForSession;
import 'package:buildsmart/screens/worker_task_detail_sheet.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🗂️ WORKER TASK BOARD (#114) — a hierarchical, status-GROUPED view of the
/// LOGGED worker's tasks, reached from the worker board's משימות tab. Where the
/// journal home (`worker_app_screen.dart`) shows TODAY's three buckets, this
/// board lays ALL of the worker's tasks out grouped by their live status, each
/// group collapsible with a live count, so the worker can scan the whole
/// pipeline and dive into any task.
///
/// 🔒 BOARD GATE (#66, חוק: מבחוץ לא רואים כלום): without a worker
/// [BoardSession] the build returns ONLY the registration gate
/// ([WelcomeScreen] in role mode) — no board content is constructed.
///
/// 🪜 DIVE — HONEST DEPTH: a task row dives via the existing
/// [showWorkerTaskDetailSheet] (#71) — the task→steps level, which is the
/// DEEPEST REAL tier. There is NO separate "stage" tier in the §6 model
/// (`TaskItem` carries no stage), so none is invented here. Each card shows a
/// real `doneSteps.length/steps.length` progress hint off the live engine.
///
/// LIVE: reads [tasksProvider] (the §6 engine) filtered to `t.worker == worker`.
/// Empty groups render an honest empty line — never a fabricated row.
class WorkerTaskBoardScreen extends ConsumerWidget {
  const WorkerTaskBoardScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const WorkerTaskBoardScreen());

  /// The status groups, in the contract's order: פעילות → נדחו → בתור →
  /// בבדיקה → הושלמו. Each group is a SET of engine statuses; the worker's
  /// `'proposed'` proposals (awaiting the contractor's approval) FOLD into בתור
  /// — owner decision A5, NO separate group. Every engine status still maps to
  /// exactly ONE group, so the group counts sum to the worker's total.
  static const List<({Set<String> statuses, String title})> _groups = [
    (statuses: {'active'}, title: '🔨 פעילות'),
    (statuses: {'rejected'}, title: '↩️ נדחו'),
    (statuses: {'pending', 'proposed'}, title: '⏳ בתור'),
    (statuses: {'review'}, title: '📸 בבדיקה'),
    (statuses: {'done'}, title: '✅ הושלמו'),
  ];

  /// PURE grouping (testable): bucket [tasks] into [_groups] order — each group
  /// its matching tasks, input order preserved. A `'proposed'` task lands in
  /// בתור, never a group of its own; every task falls in exactly one group.
  @visibleForTesting
  static List<({String title, List<TaskItem> tasks})> groupByStatus(
    List<TaskItem> tasks,
  ) =>
      [
        for (final g in _groups)
          (
            title: g.title,
            tasks: [
              for (final t in tasks)
                if (g.statuses.contains(t.status)) t,
            ],
          ),
      ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔒 BOARD GATE (#66) — mirror every board screen: no worker session ⇒
    // only the registration gate is built (the welcome screen in role mode).
    final session = ref.watch(boardAuthProvider);
    if (session == null || session.role != BoardRole.worker) {
      return const WelcomeScreen(boardRole: BoardRole.worker);
    }
    final worker = workerIndexForSession(session);

    // The logged worker's tasks (LIVE), sorted by id for a stable order inside
    // each group (the engine list is already id-seeded; this keeps it stable
    // through runtime status changes).
    final mine = ref.watch(tasksProvider).where((t) => t.worker == worker).toList()
      ..sort((a, b) => a.id.compareTo(b.id));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(
          backgroundColor: BsTokens.cardLight,
          elevation: 0,
          titleSpacing: BsTokens.space4,
          iconTheme: const IconThemeData(color: BsTokens.mutedLight),
          title: const Text(
            '🗂️ לוח משימות מלא',
            style: TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            BsTokens.space4,
            BsTokens.space4,
            BsTokens.space4,
            BsTokens.space5,
          ),
          children: [
            // A one-line honest summary so the board reads correctly even when
            // the worker has no tasks at all (every group would be empty).
            Padding(
              padding: const EdgeInsets.only(bottom: BsTokens.space2),
              child: Text(
                mine.isEmpty
                    ? 'אין משימות משויכות אליך כרגע'
                    : 'כל המשימות שלך — ${mine.length} סה"כ, מקובצות לפי מצב',
                style: const TextStyle(
                  color: BsTokens.mutedLight,
                  fontSize: 13.5,
                ),
              ),
            ),
            for (final g in groupByStatus(mine))
              _StatusGroup(title: g.title, tasks: g.tasks),
          ],
        ),
      ),
    );
  }
}

/// One collapsible status group — header (title + live count) that expands to
/// the task rows. Groups with tasks start expanded; empty groups start
/// collapsed and reveal an honest empty line when opened. ≥48dp header tap.
class _StatusGroup extends StatefulWidget {
  const _StatusGroup({required this.title, required this.tasks});

  final String title;
  final List<TaskItem> tasks;

  @override
  State<_StatusGroup> createState() => _StatusGroupState();
}

class _StatusGroupState extends State<_StatusGroup> {
  late bool _open = widget.tasks.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final count = widget.tasks.length;
    return Container(
      margin: const EdgeInsets.only(bottom: BsTokens.space3),
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
          // ── header: title + live count + expand chevron ──
          Semantics(
            button: true,
            // The header toggles the group; announce its state + count.
            label: '${widget.title} · $count משימות'
                '${_open ? ' · פתוח' : ' · סגור'}',
            excludeSemantics: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(BsTokens.radiusCard),
              onTap: () => setState(() => _open = !_open),
              child: Container(
                constraints: const BoxConstraints(minHeight: 56),
                padding: const EdgeInsets.symmetric(
                  horizontal: BsTokens.space4,
                  vertical: BsTokens.space3,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          color: BsTokens.inkLight,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    // Live count pill.
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F3F5),
                        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: BsTokens.mutedLight,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: BsTokens.space2),
                    Icon(
                      _open ? Icons.expand_less : Icons.expand_more,
                      size: 22,
                      color: BsTokens.mutedLight,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // ── body: rows, or an honest empty line ──
          if (_open) ...[
            const Divider(height: 1, color: BsTokens.divider),
            if (widget.tasks.isEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  BsTokens.space4,
                  BsTokens.space3,
                  BsTokens.space4,
                  BsTokens.space4,
                ),
                child: Text(
                  'אין משימות במצב זה',
                  style: TextStyle(color: BsTokens.mutedLight, fontSize: 13.5),
                ),
              )
            else
              for (var i = 0; i < widget.tasks.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    indent: BsTokens.space4,
                    endIndent: BsTokens.space4,
                    color: BsTokens.divider,
                  ),
                _TaskRow(task: widget.tasks[i]),
              ],
          ],
        ],
      ),
    );
  }
}

/// One task row inside a status group — name + a real `doneSteps/steps`
/// progress hint, diving via [showWorkerTaskDetailSheet] (#71, the deepest real
/// tier). ≥48dp tap target; chevron_left is the RTL "dive in" affordance.
class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.task});

  final TaskItem task;

  /// Real per-step progress (#3): submitted/approved tasks read as fully done
  /// (the engine clears doneSteps on submit but the work IS complete); an open
  /// task shows its persisted ticks. No steps → a "no steps" hint, not a fake
  /// fraction.
  String _progressHint() {
    final total = task.steps.length;
    if (total == 0) return 'אין שלבים מוגדרים';
    final submitted = task.status == 'review' || task.status == 'done';
    final done = submitted ? total : task.doneSteps.length;
    return '✓ $done/$total שלבים';
  }

  @override
  Widget build(BuildContext context) {
    final total = task.steps.length;
    final submitted = task.status == 'review' || task.status == 'done';
    final done = submitted ? total : task.doneSteps.length;
    final progress = total == 0 ? 0.0 : done / total;

    return Semantics(
      button: true,
      label: '${task.name} · ${_progressHint()}',
      excludeSemantics: true,
      child: InkWell(
        // #114 dive — the existing #71 detail sheet (steps/הוראות/תמונה). This
        // is the deepest REAL tier; no invented stage level.
        onTap: () => showWorkerTaskDetailSheet(context, taskId: task.id),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.all(BsTokens.space4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.name,
                      style: const TextStyle(
                        color: BsTokens.inkLight,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: BsTokens.space1),
                    Text(
                      '🕒 ${task.days} ימים · ${_progressHint()}',
                      style: const TextStyle(
                        color: BsTokens.mutedLight,
                        fontSize: 12.5,
                      ),
                    ),
                    if (total > 0) ...[
                      const SizedBox(height: BsTokens.space2),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFEDEDED),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            BsTokens.brand,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: BsTokens.space2),
              const Icon(
                Icons.chevron_left,
                size: 22,
                color: BsTokens.mutedLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
