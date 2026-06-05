import 'package:buildsmart/data/persona_data.dart';
import 'package:buildsmart/state/worker_tasks_engine.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🦺 עובד — the field-worker role app. Same shell/style as the contractor app
/// (white AppBar + card list); only the content differs. Faithful port of the
/// prototype `renderWorker()` (proto 06 §4.2): a worker picker, a summary, and
/// the three task buckets (current / queue / submitted) as task cards.
///
/// Now LIVE (cross-persona wiring W3): the task list comes from the shared
/// [workerTasksProvider] (not the static const), and a current-bucket task card
/// carries a "שלח לאישור" action that moves it to `review` (📸 ממתין לאישור) on
/// that shared engine — where the 👔 manager's approvals view picks it up and can
/// approve/reject it, reflecting live back here.
///
/// Reached from the role picker ("מי אתה?" → עובד). R8 — every string/number
/// is verbatim from `persona_data.dart`.
class WorkerAppScreen extends ConsumerStatefulWidget {
  const WorkerAppScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const WorkerAppScreen());

  @override
  ConsumerState<WorkerAppScreen> createState() => _WorkerAppScreenState();
}

class _WorkerAppScreenState extends ConsumerState<WorkerAppScreen> {
  int _worker = 0;

  /// Live tasks of [_worker] whose status is in [statuses] — the bucket filter
  /// over the SHARED [workerTasksProvider] list (the live equivalent of the
  /// static `tasksFor`).
  List<PersonaTask> _bucket(List<PersonaTask> all, Set<String> statuses) => all
      .where((t) => t.worker == _worker && statuses.contains(t.status))
      .toList();

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(workerTasksProvider);
    final mine = all.where((t) => t.worker == _worker).toList();

    final current = _bucket(all, {'active', 'rejected'});
    final queue = _bucket(all, {'pending'});
    final submitted = _bucket(all, {'review', 'done'});
    final total = mine.length;
    final done = _bucket(all, {'done'}).length;
    final hasActive = _bucket(all, {'active'}).isNotEmpty;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: BsTokens.bgLight,
        appBar: AppBar(
          backgroundColor: BsTokens.cardLight,
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: BsTokens.space4,
          title: const Text(
            '🦺 עובד',
            style: TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text(
                '‹ יציאה',
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 14),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            BsTokens.space4,
            BsTokens.space4,
            BsTokens.space4,
            BsTokens.space5,
          ),
          children: [
            _WorkerPicker(
              selected: _worker,
              onSelect: (i) => setState(() => _worker = i),
            ),
            const SizedBox(height: BsTokens.space3),
            _SummaryCard(
              name: workerShortName(_worker),
              done: done,
              total: total,
              activeCount: hasActive ? 1 : 0,
              queueCount: queue.length,
              submittedCount: submitted.length,
              hasActive: hasActive,
              hasQueue: queue.isNotEmpty,
            ),
            const SizedBox(height: BsTokens.space4),
            _Section(
              header:
                  current.isEmpty
                      ? '🎉 אין משימה פעילה כרגע'
                      : '🔨 המשימה הנוכחית שלך',
              tasks: current,
              // Only the current bucket (active/rejected) can be submitted.
              onSubmit: _submit,
            ),
            _Section(header: '⏳ הבאות בתור (${queue.length})', tasks: queue),
            _Section(
              header: '📋 שהגשת (${submitted.length})',
              tasks: submitted,
            ),
          ],
        ),
      ),
    );
  }

  /// WORKER submit — "שלח לאישור": move the task to `review` on the SHARED
  /// engine (where the manager's approvals view shows it) and toast the worker.
  void _submit(PersonaTask task) {
    ref.read(workerTasksProvider.notifier).submitForReview(task.id);
    showToast(context, '📸 נשלח לאישור המנהל');
  }
}

/// Worker selector chips (רן (עובד) / עומר (עובד)) — mirrors the prototype's
/// worker picker buttons.
class _WorkerPicker extends StatelessWidget {
  const _WorkerPicker({required this.selected, required this.onSelect});

  final int selected;
  final void Function(int) onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < kWorkers.length; i++) ...[
          if (i > 0) const SizedBox(width: BsTokens.space2),
          Expanded(
            child: Material(
              color: i == selected ? BsTokens.brand : BsTokens.cardLight,
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
              child: InkWell(
                borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                onTap: () => onSelect(i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: BsTokens.space3,
                  ),
                  child: Text(
                    kWorkers[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: i == selected ? Colors.white : BsTokens.inkLight,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Greeting + progress summary (`ww-summary`).
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.name,
    required this.done,
    required this.total,
    required this.activeCount,
    required this.queueCount,
    required this.submittedCount,
    required this.hasActive,
    required this.hasQueue,
  });

  final String name;
  final int done;
  final int total;
  final int activeCount;
  final int queueCount;
  final int submittedCount;
  final bool hasActive;
  final bool hasQueue;

  @override
  Widget build(BuildContext context) {
    final sub =
        hasActive
            ? 'יש לך משימה פעילה'
            : hasQueue
            ? 'יש משימות בתור'
            : 'אין משימות פתוחות';
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'שלום, $name 👷',
                      style: const TextStyle(
                        color: BsTokens.inkLight,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      style: const TextStyle(
                        color: BsTokens.mutedLight,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: BsTokens.space3,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0E3),
                  borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                ),
                child: Text(
                  '$done/$total',
                  style: const TextStyle(
                    color: BsTokens.brandDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: BsTokens.space3),
          ClipRRect(
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : done / total,
              minHeight: 8,
              backgroundColor: const Color(0xFFEDEDED),
              valueColor: const AlwaysStoppedAnimation<Color>(BsTokens.brand),
            ),
          ),
          const SizedBox(height: BsTokens.space3),
          Row(
            children: [
              _Stat(value: '$activeCount', label: 'פעילה'),
              _Stat(value: '$queueCount', label: 'בתור'),
              _Stat(value: '$submittedCount', label: 'הוגשו'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// A titled task group; empty groups still show the header (verbatim count).
/// When [onSubmit] is given, a submittable task card (status `active`/`rejected`)
/// shows a "שלח לאישור" button that invokes it (the current bucket only).
class _Section extends StatelessWidget {
  const _Section({required this.header, required this.tasks, this.onSubmit});

  final String header;
  final List<PersonaTask> tasks;
  final void Function(PersonaTask)? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            BsTokens.space1,
            BsTokens.space4,
            BsTokens.space1,
            BsTokens.space2,
          ),
          child: Text(
            header,
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ),
        for (final t in tasks) _TaskCard(task: t, onSubmit: onSubmit),
      ],
    );
  }
}

/// A single task, in the app's card style (white rounded card). When [onSubmit]
/// is provided AND the task is in a submittable status (`active`/`rejected`), a
/// "שלח לאישור" button is shown that calls it.
class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, this.onSubmit});

  final PersonaTask task;
  final void Function(PersonaTask)? onSubmit;

  /// Submittable = a worker-owned status the manager has not yet seen.
  bool get _canSubmit =>
      onSubmit != null && (task.status == 'active' || task.status == 'rejected');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BsTokens.space2),
      child: Material(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        elevation: 1,
        shadowColor: Colors.black26,
        child: Padding(
          padding: const EdgeInsets.all(BsTokens.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F3F5),
                  borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                ),
                child: Text(
                  kTaskStatusLabel[task.status] ?? '',
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
              ),
              const SizedBox(height: BsTokens.space2),
              Text(
                task.name,
                style: const TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: BsTokens.space1),
              Text(
                '🕒 ${task.days} ימים · ${task.steps} שלבים',
                style: const TextStyle(
                  color: BsTokens.mutedLight,
                  fontSize: 13,
                ),
              ),
              if (task.note.isNotEmpty) ...[
                const SizedBox(height: BsTokens.space1),
                Text(
                  task.note,
                  style: const TextStyle(
                    color: BsTokens.mutedLight,
                    fontSize: 12.5,
                  ),
                ),
              ],
              if (_canSubmit) ...[
                const SizedBox(height: BsTokens.space3),
                _SubmitButton(
                  key: ValueKey('submit-${task.id}'),
                  onPressed: () => onSubmit!(task),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The "שלח לאישור" action on a current-bucket task — a `brand`-fill pill (the
/// worker app's own accent, matching the selected worker-picker chip). White
/// text; keyed `submit-<id>` so the W3 test can tap exactly this task's button.
class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'שלח לאישור',
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Material(
          color: BsTokens.brand,
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          child: InkWell(
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
            onTap: onPressed,
            child: const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: BsTokens.space4,
                vertical: 9,
              ),
              child: Text(
                '📸 שלח לאישור',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
