import 'package:buildsmart/data/persona_data.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:buildsmart/state/worker_tasks_engine.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🦺 WORKER TASK DETAIL SHEET (board W, task #71) — tapping any task card on
/// the worker board opens this: the task's REAL data from the live
/// [tasksProvider] (the §6 engine — verbatim `detail`/`steps` seeds, the
/// existing `photo`/`note` fields), rendered as description + step checklist +
/// progress + the existing worker actions. Style mirrors `tasks_screen.dart`'s
/// `_TaskSheet`, scoped to the WORKER role only (no manager decide block —
/// the manager decides on their own board).
///
/// No new fake state: every action is an existing engine call
/// ([TasksNotifier.attachPhoto] / [TasksNotifier.submitForReview], dual-written
/// through [submitWorkerTaskForReview]); the step ticks are a session-local
/// checklist aid only — the engine has no per-step completion field yet.
/// SERVER-SWAP: per-step completion persists once the server lands.

/// WORKER submit — "שלח לאישור", dual-written to BOTH existing engines (the
/// W3 BRIDGE, see `worker_app_screen.dart`): the rich [tasksProvider] the
/// worker board reads (its auto-advance promotes the worker's next queued
/// task, proto :8133-8145) AND the legacy [workerTasksProvider] the 👔 manager
/// dashboard's approvals queue still reads — so the submission surfaces there
/// live, exactly as before. Both calls are no-ops outside a worker-owned
/// status, so the dual-write can never double-submit.
void submitWorkerTaskForReview(WidgetRef ref, int id, {String? note}) {
  ref.read(tasksProvider.notifier).submitForReview(id, note: note);
  ref.read(workerTasksProvider.notifier).submitForReview(id);
}

/// Opens the worker task-detail sheet for [taskId] (#71 — any task card).
Future<void> showWorkerTaskDetailSheet(
  BuildContext context, {
  required int taskId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => WorkerTaskDetailSheet(taskId: taskId),
  );
}

class WorkerTaskDetailSheet extends ConsumerStatefulWidget {
  const WorkerTaskDetailSheet({required this.taskId, super.key});

  /// The [TaskItem.id] to show — resolved LIVE off [tasksProvider] on build,
  /// so a submit/photo from inside the sheet reflects at once.
  final int taskId;

  @override
  ConsumerState<WorkerTaskDetailSheet> createState() =>
      _WorkerTaskDetailSheetState();
}

class _WorkerTaskDetailSheetState
    extends ConsumerState<WorkerTaskDetailSheet> {
  late final TextEditingController _note;

  /// Session-local step ticks — a checklist aid for the worker while doing the
  /// job (see the library doc: no per-step engine field yet, so nothing here
  /// pretends to persist).
  final Set<int> _checked = {};

  @override
  void initState() {
    super.initState();
    final match =
        ref.read(tasksProvider).where((x) => x.id == widget.taskId).toList();
    _note = TextEditingController(text: match.isEmpty ? '' : match.first.note);
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _submit(TaskItem t) {
    submitWorkerTaskForReview(ref, t.id, note: _note.text);
    Navigator.of(context).pop();
    showToast(context, '📸 נשלח לאישור המנהל');
  }

  @override
  Widget build(BuildContext context) {
    // Re-read live so an attach/submit from inside the sheet reflects.
    final match =
        ref.watch(tasksProvider).where((x) => x.id == widget.taskId).toList();
    if (match.isEmpty) {
      // Honest empty state — the id no longer exists on the engine.
      return _sheetShell(
        children: const [
          Text(
            'המשימה לא נמצאה',
            textAlign: TextAlign.center,
            style: TextStyle(color: BsTokens.mutedLight, fontSize: 14),
          ),
        ],
      );
    }
    final t = match.first;

    // Worker-owned statuses can report; review/done are already submitted.
    final canReport = t.status == 'active' || t.status == 'rejected';
    final submitted = t.status == 'review' || t.status == 'done';
    final stepsTotal = t.steps.length;
    final stepsDone = submitted ? stepsTotal : _checked.length;
    final progress =
        stepsTotal == 0 ? (submitted ? 1.0 : 0.0) : stepsDone / stepsTotal;

    return _sheetShell(
      children: [
        // ── header: status + name + meta ──
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0E3),
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
            ),
            child: Text(
              kTaskStatusLabel[t.status] ?? '',
              style: const TextStyle(
                color: BsTokens.brandDark,
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: BsTokens.space3),
        Text(
          t.name,
          style: const TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '🕒 ${t.days} ימים · ${t.steps.length} שלבים',
          style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13),
        ),
        if (t.status == 'pending') ...[
          const SizedBox(height: BsTokens.space2),
          // Honest: this is exactly the engine's auto-advance behavior.
          const Text(
            'משימה בתור — תעבור לביצוע אוטומטית כשתוגש המשימה הנוכחית.',
            style: TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
          ),
        ],

        // ── description / instructions (verbatim seed `detail`) ──
        const SizedBox(height: BsTokens.space3),
        const _SecH('תיאור והוראות'),
        Text(
          t.detail.isNotEmpty ? t.detail : 'אין הוראות נוספות למשימה זו',
          style: TextStyle(
            color: t.detail.isNotEmpty ? BsTokens.inkLight : BsTokens.mutedLight,
            fontSize: 13.5,
          ),
        ),

        // ── step checklist (verbatim seed `steps`) + progress ──
        const SizedBox(height: BsTokens.space3),
        const _SecH('שלבי ביצוע'),
        if (t.steps.isEmpty)
          // Honest: this task has no step list on the seed.
          const Text(
            'לא הוגדרו שלבים למשימה זו',
            style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
          )
        else
          for (var i = 0; i < t.steps.length; i++)
            CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: BsTokens.brand,
              // Submitted/approved tasks show the full checklist done; an open
              // task ticks locally (session aid — see library doc).
              value: submitted || _checked.contains(i),
              onChanged: canReport
                  ? (v) => setState(() {
                        if (v ?? false) {
                          _checked.add(i);
                        } else {
                          _checked.remove(i);
                        }
                      })
                  : null,
              title: Text(
                t.steps[i],
                style: const TextStyle(color: BsTokens.inkLight, fontSize: 13.5),
              ),
            ),
        if (t.steps.isNotEmpty) ...[
          const SizedBox(height: BsTokens.space2),
          ClipRRect(
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFEDEDED),
              valueColor: const AlwaysStoppedAnimation<Color>(BsTokens.brand),
            ),
          ),
          const SizedBox(height: BsTokens.space1),
          Text(
            submitted
                ? (t.status == 'done' ? 'המשימה אושרה ✓' : 'הוגש לאישור המנהל')
                : 'סומנו $stepsDone מתוך $stepsTotal שלבים',
            style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
          ),
        ],

        // ── photo (the existing TaskItem.photo field) ──
        if (t.photo != null) ...[
          const SizedBox(height: BsTokens.space3),
          const _SecH('תמונת ביצוע'),
          Container(
            padding: const EdgeInsets.all(BsTokens.space4),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F3F5),
              borderRadius: BorderRadius.circular(BsTokens.radiusCard),
            ),
            child: const Text(
              '📷 תמונה מהשטח (הדגמה)',
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
            ),
          ),
        ],

        // ── worker note (read-only when not reporting) ──
        if (t.note.isNotEmpty && !canReport) ...[
          const SizedBox(height: BsTokens.space3),
          const _SecH('הערת העובד'),
          Text(
            '"${t.note}"',
            style: const TextStyle(color: BsTokens.inkLight, fontSize: 13.5),
          ),
        ],

        // ── WORKER report block — the existing actions, wired to the engine ──
        if (canReport) ...[
          const SizedBox(height: BsTokens.space3),
          const _SecH('דווח על הביצוע'),
          OutlinedButton(
            onPressed: () {
              ref.read(tasksProvider.notifier).attachPhoto(t.id);
              showToast(context, 'תמונה צורפה (הדגמה)');
            },
            child: Text(t.photo != null ? '📷 החלף תמונה' : '📷 העלה תמונת ביצוע'),
          ),
          const SizedBox(height: BsTokens.space2),
          TextField(
            controller: _note,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'הערה — מה בוצע, ומה נשאר (אופציונלי)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: BsTokens.space3),
          _PrimaryBtn(
            key: const ValueKey('worker-task-submit'),
            label: '📸 שלח לאישור',
            onTap: () => _submit(t),
          ),
        ] else ...[
          const SizedBox(height: BsTokens.space4),
          _PrimaryBtn(
            label: 'סגור',
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ],
    );
  }

  /// The shared sheet chrome — RTL + draggable rounded container with the grab
  /// handle (mirrors `tasks_screen.dart`'s `_TaskSheet` shell).
  Widget _sheetShell({required List<Widget> children}) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scroll) => Container(
          decoration: const BoxDecoration(
            color: BsTokens.cardLight,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(BsTokens.radiusCard)),
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
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

/// Small section header (the `_SecH` idiom from `tasks_screen.dart`).
class _SecH extends StatelessWidget {
  const _SecH(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BsTokens.space1),
      child: Text(
        text,
        style: const TextStyle(
          color: BsTokens.inkLight,
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
      ),
    );
  }
}

/// Brand-fill pill action (the worker app's own accent — matches the board's
/// "שלח לאישור" button style).
class _PrimaryBtn extends StatelessWidget {
  const _PrimaryBtn({required this.label, required this.onTap, super.key});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: BsTokens.brand,
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: BsTokens.space4,
              vertical: 11,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: bsOnAccent(context),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
