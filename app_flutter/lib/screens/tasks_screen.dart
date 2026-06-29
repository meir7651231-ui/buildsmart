// משימות SCREEN (T3.A · proto §6 [L8023-8200]) — now the CONTRACTOR-ONLY task
// board: create tasks (＋ משימה חדשה / edit), APPROVE submitted ones, and
// APPROVE worker PROPOSALS, over the status buckets + the task-detail sheet and
// the daily work-log sheet. The manager/worker role toggle and the embedded
// worker view were REMOVED — the worker board lives in worker_app_screen.dart.
// The four tool entries (HR / נוכחות / גאנט / ליקויים) moved to Site Hub tiles.
// All state is the live `tasksProvider` (5-state machine + auto-advance, see
// state/tasks_engine.dart). Style matches worker_app_screen.dart (white AppBar +
// card list). Every string/number verbatim from the prototype (R6/R8).
//
// Entry: openTasks (the leaf action) → TasksScreen.route().

import 'package:buildsmart/data/persona_data.dart';
import 'package:buildsmart/data/phaseb_seeds.dart';
// Wave T2a — contractor authoring stamps the employer id (kDemoContractorId on
// the single-device demo, SERVER-SWAP to the real contractor uid) + reads the
// LIVE review queue projection for the parallel contractor-approval surface.
// apple-readiness (merge): the _TaskSheet photo uses the shared taskPhotoWidget.
import 'package:buildsmart/screens/worker_task_detail_sheet.dart'
    show taskPhotoWidget;
import 'package:buildsmart/services/task_photo.dart';
import 'package:buildsmart/state/board_auth.dart' show kDemoContractorId;
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:buildsmart/state/worker_tasks_engine.dart'
    show pendingApprovalTasksProvider, pendingProposalsProvider;
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/config_theme.dart' show cfgRadius;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/reject_reason_dialog.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// CRASH-GUARD — a worker index can outrun [kWorkers] (a task stamped for a
/// worker who is no longer in the demo roster, or a malformed/server payload),
/// so `kWorkers[i]` would throw a RangeError. Clamp out-of-range indices to the
/// first worker label instead of crashing the whole board.
String _wk(int i) => kWorkers[(i >= 0 && i < kWorkers.length) ? i : 0];

/// Open the משימות screen — the wire target for `openTasks`.
void openTasks(BuildContext context) =>
    Navigator.of(context).push(TasksScreen.route());

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const TasksScreen());

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  int _worker = 0; // proto `activeWorker=0`

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksProvider);
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
            '📋 משימות',
            style: TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('‹ יציאה',
                  style: TextStyle(color: BsTokens.mutedLight, fontSize: 14)),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(BsTokens.space4, BsTokens.space4,
              BsTokens.space4, BsTokens.space5),
          children: [
            ..._managerView(tasks),
          ],
        ),
      ),
    );
  }

  // ── MANAGER view (proto :8068-8081) ──────────────────────────────────────
  // CONTRACTOR surface (Wave T2a, additive): this same role is the employer's
  // task view — it now also AUTHORS tasks (＋ משימה חדשה / edit a card) and
  // APPROVES submitted ones (the parallel contractor-approval block, on the
  // same review queue the manager dashboard uses — _waveT2 PARKED decision).
  List<Widget> _managerView(List<TaskItem> tasks) {
    final review = tasks.where((t) => t.status == 'review').toList();
    final active = tasks
        .where((t) => t.status == 'active' || t.status == 'rejected')
        .toList();
    final pending = tasks.where((t) => t.status == 'pending').toList();
    final done = tasks.where((t) => t.status == 'done').toList();
    return [
      const _Intro(
        'אתה רואה את כל משימות הצוות. אשר עבודות שהוגשו ועקוב אחרי ההתקדמות.',
      ),
      const SizedBox(height: BsTokens.space2),
      // ＋ AUTHORING (Wave T2a) — open the create sheet (worker defaults to the
      // currently-picked worker index, a sensible starting assignment).
      _NewTaskButton(onTap: () => _openAuthor(context)),
      const SizedBox(height: BsTokens.space2),
      _LogButton(onTap: () => _openWorkLog(context)),
      // CONTRACTOR APPROVAL (Wave T2a) — the employer's own אשר/דחה surface on
      // the LIVE review queue (parallel to the manager dashboard's block).
      ..._contractorApprovals(),
      // CONTRACTOR PROPOSAL-APPROVAL (Wave G1c) — the SEPARATE queue of tasks a
      // WORKER PROPOSED (status `'proposed'`), adjacent to the completion block
      // above but a distinct lifecycle (approveProposal/rejectProposal).
      ..._contractorProposals(tasks),
      if (tasks.isEmpty)
        const _DoneAll('אין משימות לצוות עדיין — משימות חדשות יופיעו כאן'),
      if (review.isNotEmpty)
        _Group('📸 ממתין לאישור שלך (${review.length})', review, _open,
            onEdit: _openEdit),
      if (active.isNotEmpty)
        _Group('🔨 בביצוע עכשיו (${active.length})', active, _open,
            onEdit: _openEdit),
      if (pending.isNotEmpty)
        _Group('⏳ ממתינות בתור (${pending.length})', pending, _open,
            onEdit: _openEdit),
      if (done.isNotEmpty)
        _Group('✅ הושלמו ואושרו (${done.length})', done, _open,
            onEdit: _openEdit),
    ];
  }

  // ── CONTRACTOR approval section (Wave T2a) ───────────────────────────────
  // Reads `pendingApprovalTasksProvider` (the LIVE `review` queue projected to
  // PersonaTask, id-sorted) and decides via the existing
  // `tasksProvider.notifier.approve/reject` — the SAME engine path the manager
  // dashboard uses (parallel, not relocated). Empty → the section is omitted.
  List<Widget> _contractorApprovals() {
    // SCOPE to THIS employer's workers (mirrors _contractorProposals): the
    // PersonaTask projection carries employerId, so filter the LIVE review
    // queue by it. SERVER-SWAP: the single-device demo stamps kDemoContractorId
    // on authored tasks; the real backend filters by the session contractor uid
    // (do NOT use boardAuthProvider.employerId — the contractor session has
    // employerId=='' while tasks are stamped kDemoContractorId, which would hide
    // every task).
    final pending = [
      for (final t in ref.watch(pendingApprovalTasksProvider))
        // DEMO-SEED: unstamped seeds (employerId '') belong to the single demo
        // contractor → show them too. SERVER-SWAP: the real backend filters by
        // the session contractor uid (all tasks stamped; '' won't occur).
        if (t.employerId == kDemoContractorId || t.employerId.isEmpty) t
    ];
    if (pending.isEmpty) return const [];
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(BsTokens.space1, BsTokens.space4,
            BsTokens.space1, BsTokens.space2),
        child: Text('✅ אישורי עובדים (קבלן) (${pending.length})',
            style: const TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 15)),
      ),
      for (final t in pending)
        _ApprovalCard(
          key: ValueKey('contractor-approval-${t.id}'),
          name: t.name,
          workerLabel: _wk(t.worker),
          onApprove: () async {
            final ok = await confirmDestructive(
              context,
              title: 'אישור המשימה?',
              message: 'המשימה תסומן כהושלמה — פעולה סופית.',
              confirmLabel: 'אשר',
              confirmColor: const Color(0xFF1F8A4C),
            );
            if (!ok || !context.mounted) return;
            ref.read(tasksProvider.notifier).approve(t.id);
            showToast(context, '✅ אושר: ${t.name}');
          },
          onReject: () async {
            final why = await promptRejectReason(context);
            if (why == null || !context.mounted) return;
            ref.read(tasksProvider.notifier).reject(t.id, reason: why);
            showToast(context, '↩️ נדחה: ${t.name}');
          },
        ),
    ];
  }

  // ── CONTRACTOR proposal-approval section (Wave G1c) ──────────────────────
  // The REVERSE direction of [_contractorApprovals]: that one is the worker's
  // COMPLETION queue (`review`); THIS one is the worker's PROPOSED-new-task
  // queue (`proposed`). Reads `pendingProposalsProvider` (UNSCOPED) and scopes
  // to THIS employer's workers, then decides via the dedicated engine path
  // (`approveProposal`/`rejectProposal` — a distinct lifecycle from approve/
  // reject) and posts a worker-facing chat line (the engine already fires the
  // worker bell, so we do NOT double-fire it). Empty → the section is omitted.
  List<Widget> _contractorProposals(List<TaskItem> tasks) {
    final proposals = [
      for (final t in ref.watch(pendingProposalsProvider))
        // DEMO-SEED: unstamped seeds count as the demo contractor's (SERVER-SWAP:
        // real backend filters by session contractor uid; '' won't occur).
        if (t.employerId == kDemoContractorId || t.employerId.isEmpty) t
    ];
    if (proposals.isEmpty) return const [];
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(BsTokens.space1, BsTokens.space4,
            BsTokens.space1, BsTokens.space2),
        child: Text('📝 משימות שהעובד הציע (${proposals.length})',
            style: const TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 15)),
      ),
      const Padding(
        padding: EdgeInsets.fromLTRB(
            BsTokens.space1, 0, BsTokens.space1, BsTokens.space2),
        child: Text('עובד הציע משימה חדשה — אשר כדי שתיכנס לביצוע, או דחה.',
            style: TextStyle(color: BsTokens.mutedLight, fontSize: 13)),
      ),
      for (final t in proposals)
        _ProposalCard(
          key: ValueKey('proposal-${t.id}'),
          id: t.id,
          name: t.name,
          // `detail` lives only on the rich TaskItem (the PersonaTask
          // projection drops it) — look it up from the live list by id, and
          // fall back to '' if (somehow) absent.
          detail: tasks
              .where((x) => x.id == t.id)
              .map((x) => x.detail)
              .firstOrNull ??
              '',
          workerLabel: _wk(t.worker),
          days: t.days,
          onApprove: () {
            ref.read(tasksProvider.notifier).approveProposal(t.id);
            // The engine already fired the worker bell — only post the chat
            // line (and the contractor-side toast) here.
            ref.read(chatEngineProvider.notifier).send(
                'th-worker-contractor',
                BsRole.contractor,
                '✅ המשימה שהצעת "${t.name}" אושרה');
            showToast(context, '✅ אושרה הצעה: ${t.name}');
          },
          onReject: () async {
            final why = await promptRejectReason(context);
            // State `mounted` guard (this is a ConsumerState) after the await.
            if (why == null || !mounted) return;
            ref.read(tasksProvider.notifier).rejectProposal(t.id, reason: why);
            ref.read(chatEngineProvider.notifier).send(
                'th-worker-contractor',
                BsRole.contractor,
                '❌ המשימה שהצעת "${t.name}" נדחתה'
                '${why.isNotEmpty ? ' · $why' : ''}');
            showToast(context, '❌ נדחתה הצעה: ${t.name}');
          },
        ),
    ];
  }

  void _open(TaskItem t) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      // CONTRACTOR-ONLY board → the detail sheet always runs as the manager
      // (approver) role; the worker role lives in worker_app_screen.dart.
      builder: (_) => _TaskSheet(task: t, role: 'manager'),
    );
  }

  void _openWorkLog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _WorkLogSheet(),
    );
  }

  // CONTRACTOR authoring (Wave T2a) — open the create sheet; the new task is
  // assigned to the currently-picked worker by default (a sensible start).
  void _openAuthor(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _TaskAuthorSheet(initialWorker: _worker),
    );
  }

  // CONTRACTOR edit (Wave T2a) — open the same sheet seeded from an existing
  // task; saving patches it via editTask/assignTask (status untouched).
  void _openEdit(TaskItem t) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _TaskAuthorSheet(edit: t, initialWorker: t.worker),
    );
  }
}

// ── worker picker ────────────────────────────────────────────────────────────
// The manager/worker role toggle (_RolePicker) was removed when this screen
// became the CONTRACTOR-ONLY board. _WorkerPick survives — it is reused by the
// authoring sheet (_TaskAuthorSheet) to assign a task to a worker.
class _WorkerPick extends StatelessWidget {
  const _WorkerPick({required this.selected, required this.onSelect});
  final int selected;
  final void Function(int) onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: BsTokens.space3),
      child: Row(children: [
        for (var i = 0; i < kWorkers.length; i++) ...[
          if (i > 0) const SizedBox(width: BsTokens.space2),
          Expanded(
            child: Material(
              color: i == selected ? BsTokens.brandDark : BsTokens.cardLight,
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
              child: InkWell(
                borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                onTap: () => onSelect(i),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: BsTokens.space3),
                  child: Text(
                    _wk(i),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: i == selected ? bsOnAccent(context) : BsTokens.inkLight,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ]),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: BsTokens.space3),
        child: Text(
          text,
          style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13),
        ),
      );
}

class _LogButton extends StatelessWidget {
  const _LogButton({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        elevation: 1,
        shadowColor: Colors.black26,
        child: InkWell(
          borderRadius: BorderRadius.circular(cfgRadius(context)),
          onTap: onTap,
          child: const Padding(
            padding: EdgeInsets.all(BsTokens.space4),
            child: Text(
              '📅 יומן עבודה — מה בוצע בכל יום',
              style: TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
}

/// ＋ "משימה חדשה" — the contractor authoring affordance (Wave T2a). Brand-
/// filled to read as the primary action, sitting above the work-log button.
class _NewTaskButton extends StatelessWidget {
  const _NewTaskButton({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
        color: BsTokens.brand,
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        elevation: 1,
        shadowColor: Colors.black26,
        child: InkWell(
          key: const ValueKey('task-new'),
          borderRadius: BorderRadius.circular(cfgRadius(context)),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(BsTokens.space4),
            child: Text(
              '＋ משימה חדשה',
              style: TextStyle(
                color: bsOnAccent(context),
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
}

/// One row in the contractor's "אישורי עובדים (קבלן)" section (Wave T2a) — a
/// submitted task with אשר/דחה. Decisions run on the existing engine path
/// (`approve`/`reject`) via the callbacks; this widget is presentation only.
class _ApprovalCard extends StatelessWidget {
  const _ApprovalCard({
    required this.name,
    required this.workerLabel,
    required this.onApprove,
    required this.onReject,
    super.key,
  });
  final String name;
  final String workerLabel;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: BsTokens.space2),
        child: Material(
          color: BsTokens.cardLight,
          borderRadius: BorderRadius.circular(cfgRadius(context)),
          elevation: 1,
          shadowColor: Colors.black26,
          child: Padding(
            padding: const EdgeInsets.all(BsTokens.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: BsTokens.inkLight,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
                const SizedBox(height: 2),
                Text('👷 $workerLabel · 📸 ממתין לאישור',
                    style: const TextStyle(
                        color: BsTokens.mutedLight, fontSize: 12.5)),
                const SizedBox(height: BsTokens.space3),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      key: ValueKey('approval-reject-$name'),
                      onPressed: onReject,
                      child: const Text('↩️ החזר לתיקון'),
                    ),
                  ),
                  const SizedBox(width: BsTokens.space2),
                  Expanded(
                    child: _PrimaryBtn(
                      key: ValueKey('approval-approve-$name'),
                      label: '✅ אשר',
                      onTap: onApprove,
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      );
}

/// One row in the contractor's "📝 משימות שהעובד הציע" section (Wave G1c) — a
/// worker-PROPOSED task (status `'proposed'`) with ✅ אשר / ❌ דחה. SEPARATE from
/// [_ApprovalCard] (the `'review'` completion queue): this one shows the
/// proposed task's detail + estimated days and decides via the dedicated
/// `approveProposal`/`rejectProposal` engine path. Presentation only — the
/// decision (engine + chat + toast) runs in the callbacks. Mirrors
/// [_ApprovalCard]'s card/button look.
class _ProposalCard extends StatelessWidget {
  const _ProposalCard({
    required this.id,
    required this.name,
    required this.detail,
    required this.workerLabel,
    required this.days,
    required this.onApprove,
    required this.onReject,
    super.key,
  });
  final int id;
  final String name;
  final String detail;
  final String workerLabel;
  final int days;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: BsTokens.space2),
        child: Material(
          color: BsTokens.cardLight,
          borderRadius: BorderRadius.circular(cfgRadius(context)),
          elevation: 1,
          shadowColor: Colors.black26,
          child: Padding(
            padding: const EdgeInsets.all(BsTokens.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: BsTokens.inkLight,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
                if (detail.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(detail,
                      style: const TextStyle(
                          color: BsTokens.mutedLight, fontSize: 12.5)),
                ],
                const SizedBox(height: 2),
                Text('👷 $workerLabel · ⏱️ $days ימים · 📝 ממתין לאישורך',
                    style: const TextStyle(
                        color: BsTokens.mutedLight, fontSize: 12.5)),
                const SizedBox(height: BsTokens.space3),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      key: ValueKey('proposal-reject-$id'),
                      onPressed: onReject,
                      child: const Text('❌ דחה'),
                    ),
                  ),
                  const SizedBox(width: BsTokens.space2),
                  Expanded(
                    child: _PrimaryBtn(
                      key: ValueKey('proposal-approve-$id'),
                      label: '✅ אשר',
                      onTap: onApprove,
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      );
}

class _DoneAll extends StatelessWidget {
  const _DoneAll(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: BsTokens.space4),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      );
}

class _Group extends StatelessWidget {
  const _Group(this.header, this.tasks, this.onTap, {this.onEdit});
  final String header;
  final List<TaskItem> tasks;
  final void Function(TaskItem) onTap;

  /// Wave T2a — when provided (the contractor/manager view), each card shows a
  /// ✏️ edit affordance opening the author sheet. Null (the worker view) → no
  /// edit control, the card's existing tap-to-open behavior is unchanged.
  final void Function(TaskItem)? onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(BsTokens.space1, BsTokens.space4,
              BsTokens.space1, BsTokens.space2),
          child: Text(header,
              style: const TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 15)),
        ),
        for (final t in tasks)
          _Card(
            task: t,
            onTap: () => onTap(t),
            onEdit: onEdit == null ? null : () => onEdit!(t),
          ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.task, required this.onTap, this.onEdit});
  final TaskItem task;
  final VoidCallback onTap;

  /// Wave T2a — optional ✏️ edit tap (contractor authoring). Null → no button.
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BsTokens.space2),
      child: Material(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        elevation: 1,
        shadowColor: Colors.black26,
        child: InkWell(
          key: ValueKey('task-${task.id}'),
          borderRadius: BorderRadius.circular(cfgRadius(context)),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(BsTokens.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F3F5),
                        borderRadius:
                            BorderRadius.circular(BsTokens.radiusPill),
                      ),
                      child: Text(
                        kTaskStatusLabel[task.status] ?? '',
                        style: const TextStyle(
                            color: BsTokens.inkLight,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5),
                      ),
                    ),
                    const Spacer(),
                    // Wave T2a — ✏️ edit affordance (contractor authoring only).
                    if (onEdit != null)
                      InkWell(
                        key: ValueKey('task-edit-${task.id}'),
                        borderRadius:
                            BorderRadius.circular(BsTokens.radiusPill),
                        onTap: onEdit,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Text('✏️ ערוך',
                              style: TextStyle(
                                  color: BsTokens.brandDark,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: BsTokens.space2),
                Text(task.name,
                    style: const TextStyle(
                        color: BsTokens.inkLight,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
                if (task.detail.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(task.detail,
                      style: const TextStyle(
                          color: BsTokens.mutedLight, fontSize: 12.5)),
                ],
                const SizedBox(height: BsTokens.space1),
                Text(
                  '👷 ${_wk(task.worker)} · 📋 ${task.steps.length} שלבים · ⏱️ ${task.days} ימים',
                  style: const TextStyle(
                      color: BsTokens.mutedLight, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── task detail sheet ───────────────────────────────────────────────────────
class _TaskSheet extends ConsumerStatefulWidget {
  const _TaskSheet({required this.task, required this.role});
  final TaskItem task;
  final String role;
  @override
  ConsumerState<_TaskSheet> createState() => _TaskSheetState();
}

class _TaskSheetState extends ConsumerState<_TaskSheet> {
  late final TextEditingController _note =
      TextEditingController(text: widget.task.note);

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Re-read live so an approve/reject from inside the sheet reflects.
    final t = ref
        .watch(tasksProvider)
        .firstWhere((x) => x.id == widget.task.id, orElse: () => widget.task);
    final canReport =
        widget.role == 'worker' && (t.status == 'active' || t.status == 'rejected');
    final canDecide = widget.role == 'manager' && t.status == 'review';

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
              Text(t.name,
                  style: const TextStyle(
                      color: BsTokens.inkLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 18)),
              const SizedBox(height: 2),
              Text('👷 ${_wk(t.worker)}',
                  style: const TextStyle(
                      color: BsTokens.mutedLight, fontSize: 13)),
              const SizedBox(height: BsTokens.space3),
              _statusPill(t.status),
              const SizedBox(height: BsTokens.space3),
              const _SecH('תיאור המשימה'),
              Text(t.detail,
                  style: const TextStyle(
                      color: BsTokens.inkLight, fontSize: 13.5)),
              if (t.steps.isNotEmpty) ...[
                const SizedBox(height: BsTokens.space3),
                const _SecH('שלבי ביצוע'),
                for (final s in t.steps)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Text('• $s',
                        style: const TextStyle(
                            color: BsTokens.inkLight, fontSize: 13)),
                  ),
              ],
              if (t.photo != null) ...[
                const SizedBox(height: BsTokens.space3),
                const _SecH('תמונת ביצוע'),
                // #85ב — the SHARED dual-render helper: a real data-URL/https
                // photo renders the actual image; the legacy 'demo' marker keeps
                // its honest placeholder (and, under kHideUnderConstruction, the
                // helper hides that placeholder entirely). The old static gray
                // box never showed a real photo even when one existed.
                taskPhotoWidget(t.photo, context: context),
              ],
              if (t.note.isNotEmpty && !canReport) ...[
                const SizedBox(height: BsTokens.space3),
                const _SecH('הערת העובד'),
                Text('"${t.note}"',
                    style: const TextStyle(
                        color: BsTokens.inkLight, fontSize: 13.5)),
              ],
              // WORKER report block
              if (canReport) ...[
                const SizedBox(height: BsTokens.space3),
                const _SecH('דווח על הביצוע'),
                OutlinedButton(
                  onPressed: () async {
                    // #85ב — a REAL capture (webcam on web / camera on mobile),
                    // the SAME pickTaskPhoto flow the worker detail sheet uses;
                    // null = honest cancel, nothing attached. We NEVER toast
                    // "תמונה צורפה" without an actual photo (the old path stored
                    // a fake 'demo' marker and claimed success — Apple blocker).
                    final dataUrl = await pickTaskPhoto(context);
                    if (!context.mounted) return;
                    if (dataUrl == null) {
                      showToast(context, 'לא צולמה תמונה');
                      return;
                    }
                    ref.read(tasksProvider.notifier).attachPhoto(t.id, dataUrl);
                    showToast(context, '📷 תמונת ההוכחה צורפה');
                  },
                  child: Text(t.photo != null
                      ? '📷 החלף תמונה'
                      : '📷 העלה תמונת ביצוע'),
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
                  key: const ValueKey('task-submit'),
                  label: 'שלח לאישור המנהל',
                  onTap: () {
                    ref
                        .read(tasksProvider.notifier)
                        .submitForReview(t.id, note: _note.text);
                    Navigator.of(context).pop();
                    showToast(context, 'נשלח לאישור המנהל ✓');
                  },
                ),
              ],
              // MANAGER decide block
              if (canDecide) ...[
                const SizedBox(height: BsTokens.space3),
                const Text(
                  'העובד הגיש את המשימה. אשר אם בוצעה כראוי, או החזר לתיקון.',
                  style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
                ),
                const SizedBox(height: BsTokens.space3),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      key: const ValueKey('task-reject'),
                      onPressed: () async {
                        // 📝 #12 — reject with an OPTIONAL reason (the shared
                        // promptRejectReason dialog): null = cancelled, no
                        // reject; the reason is threaded to the engine
                        // (side-map + the worker's 🔁 bell notification).
                        final why = await promptRejectReason(context);
                        if (why == null || !context.mounted) return;
                        ref
                            .read(tasksProvider.notifier)
                            .reject(t.id, reason: why);
                        Navigator.of(context).pop();
                        showToast(context, 'המשימה הוחזרה לעובד לתיקון');
                      },
                      child: const Text('↩️ החזר לתיקון'),
                    ),
                  ),
                  const SizedBox(width: BsTokens.space2),
                  Expanded(
                    child: _PrimaryBtn(
                      key: const ValueKey('task-approve'),
                      label: '✅ אשר',
                      onTap: () async {
                        final ok = await confirmDestructive(
                          context,
                          title: 'אישור המשימה?',
                          message: 'המשימה תסומן כהושלמה — פעולה סופית.',
                          confirmLabel: 'אשר',
                          confirmColor: const Color(0xFF1F8A4C),
                        );
                        if (!ok || !context.mounted) return;
                        ref.read(tasksProvider.notifier).approve(t.id);
                        Navigator.of(context).pop();
                        showToast(context, 'המשימה אושרה ✓');
                      },
                    ),
                  ),
                ]),
              ],
              if (!canReport && !canDecide) ...[
                const SizedBox(height: BsTokens.space4),
                _PrimaryBtn(
                  label: 'סגור',
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusPill(String status) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0E3),
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          ),
          child: Text(kTaskStatusLabel[status] ?? '',
              style: const TextStyle(
                  color: BsTokens.brandDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 13)),
        ),
      );
}

/// `dd.MM.yyyy` zero-padded date label for the author start-date button (Wave
/// G2b) — a small local formatter (no dart:intl in this codebase). Only ever
/// called with a date the contractor actually picked (never invented).
String _fmtAuthorDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.'
    '${d.month.toString().padLeft(2, '0')}.${d.year}';

class _SecH extends StatelessWidget {
  const _SecH(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(text,
            style: const TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 13.5)),
      );
}

class _PrimaryBtn extends StatelessWidget {
  const _PrimaryBtn({required this.label, required this.onTap, super.key});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
        color: BsTokens.brand,
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: bsOnAccent(context),
                    fontWeight: FontWeight.w800,
                    fontSize: 14)),
          ),
        ),
      );
}

// ── work-log sheet (proto openTaskLog :8158) ────────────────────────────────
class _WorkLogSheet extends ConsumerWidget {
  const _WorkLogSheet();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final log = ref.watch(workLogProvider);
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
              const Text('יומן עבודה',
                  style: TextStyle(
                      color: BsTokens.inkLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 18)),
              const SizedBox(height: 2),
              const Text('סיכום יומי — מה בוצע בפרויקט',
                  style: TextStyle(color: BsTokens.mutedLight, fontSize: 13)),
              const SizedBox(height: BsTokens.space3),
              for (final day in log) _logDay(day),
            ],
          ),
        ),
      ),
    );
  }

  // (context-less helper — keeps the fixed radius; adopt when context is threaded.)
  Widget _logDay(WorkLogDay day) {
    final doneCount = day.items.where((i) => i.status == 'done').length;
    return Container(
      margin: const EdgeInsets.only(bottom: BsTokens.space3),
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📅 ${day.date}',
              style: const TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 14)),
          Text('$doneCount משימות הושלמו',
              style:
                  const TextStyle(color: BsTokens.mutedLight, fontSize: 12)),
          const SizedBox(height: BsTokens.space2),
          for (final it in day.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(it.status == 'done' ? '✅' : '·',
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: BsTokens.space2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(it.task,
                            style: const TextStyle(
                                color: BsTokens.inkLight, fontSize: 13)),
                        if (it.worker != '—')
                          Text('👷 ${it.worker}',
                              style: const TextStyle(
                                  color: BsTokens.mutedLight, fontSize: 11.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── contractor authoring sheet (Wave T2a) ────────────────────────────────────
/// Create OR edit a task (the same form). [edit] null → CREATE (mints a new id,
/// stamps `employerId`); non-null → EDIT (patches name/detail/days/steps via
/// `editTask`, and re-assigns via `assignTask` when the worker changed — status
/// and all runtime fields are left untouched). RTL, styled like [_TaskSheet].
class _TaskAuthorSheet extends ConsumerStatefulWidget {
  const _TaskAuthorSheet({this.edit, this.initialWorker = 0});

  /// The task being edited, or null for a fresh create.
  final TaskItem? edit;

  /// The worker index pre-selected on a CREATE (the screen's current pick).
  final int initialWorker;

  @override
  ConsumerState<_TaskAuthorSheet> createState() => _TaskAuthorSheetState();
}

class _TaskAuthorSheetState extends ConsumerState<_TaskAuthorSheet> {
  late final TextEditingController _name =
      TextEditingController(text: widget.edit?.name ?? '');
  late final TextEditingController _detail =
      TextEditingController(text: widget.edit?.detail ?? '');
  // Steps are authored one-per-line — joined for editing, split on save.
  late final TextEditingController _steps =
      TextEditingController(text: (widget.edit?.steps ?? const []).join('\n'));
  late final TextEditingController _days = TextEditingController(
      text: (widget.edit?.days ?? 1).toString());
  late int _worker = widget.edit?.worker ?? widget.initialWorker;

  // 📅 GANTT anchor (Wave G2b) — the optional planned start date for the
  // timeline. Preloaded from the edited task (null = unscheduled, the create
  // default). Just a nullable DateTime in State — no controller to dispose.
  late DateTime? _scheduledStart = widget.edit?.scheduledStart;

  bool get _isEdit => widget.edit != null;

  @override
  void dispose() {
    _name.dispose();
    _detail.dispose();
    _steps.dispose();
    _days.dispose();
    super.dispose();
  }

  /// Parse the steps box into a clean list — one step per non-empty line.
  List<String> _parseSteps() => _steps.text
      .split('\n')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      showToast(context, 'יש להזין שם משימה');
      return;
    }
    final detail = _detail.text.trim();
    final steps = _parseSteps();
    // A non-positive / unparseable day count falls back to 1 (the seed minimum).
    final days = int.tryParse(_days.text.trim());
    final safeDays = (days == null || days < 1) ? 1 : days;
    final notifier = ref.read(tasksProvider.notifier);
    if (_isEdit) {
      final id = widget.edit!.id;
      notifier.editTask(id,
          name: name,
          detail: detail,
          days: safeDays,
          steps: steps,
          // 📅 GANTT (Wave G2b) — re-anchor the planned start. editTask SETS a
          // non-null date; here it's null only when the task was never scheduled
          // and the contractor didn't pick one (keeps it unscheduled).
          scheduledStart: _scheduledStart);
      // Re-assign only when the picked worker actually changed (keeps the
      // overlay byte-stable otherwise). The server-ready uid stays the demo
      // fallback — the int index is the addressing today.
      if (_worker != widget.edit!.worker) {
        notifier.assignTask(id, worker: _worker);
      }
      Navigator.of(context).pop();
      showToast(context, 'המשימה עודכנה ✓');
    } else {
      notifier.createTask(
        name: name,
        detail: detail,
        days: safeDays,
        steps: steps,
        worker: _worker,
        // SERVER-SWAP: the single-device demo has one contractor → stamp the
        // demo employer id (kDemoContractorId). When the backend lands this is
        // the real contractor uid from the session/auth claim.
        employerId: kDemoContractorId,
        // 📅 GANTT (Wave G2b) — additive: the picked start date lands the task
        // on the timeline; null (no pick) keeps today's unscheduled behavior.
        scheduledStart: _scheduledStart,
      );
      Navigator.of(context).pop();
      showToast(context, 'המשימה נוצרה ✓');
    }
  }

  /// 📅 GANTT (Wave G2b) — pick the task's planned start date (the timeline
  /// anchor). DateTime.now() is used only inside this interactive callback to
  /// seed the picker bounds (a window of ±2 years), never to fabricate a stored
  /// date: the State keeps null until the contractor actually picks one.
  Future<void> _pickStart() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledStart ?? now,
      firstDate: DateTime(now.year - 2, now.month, now.day),
      lastDate: DateTime(now.year + 2, now.month, now.day),
    );
    if (picked == null) return;
    setState(() => _scheduledStart = picked);
  }

  @override
  Widget build(BuildContext context) {
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
              Text(_isEdit ? 'עריכת משימה' : 'משימה חדשה',
                  style: const TextStyle(
                      color: BsTokens.inkLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 18)),
              const SizedBox(height: BsTokens.space3),
              const _SecH('שם המשימה'),
              TextField(
                key: const ValueKey('author-name'),
                controller: _name,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'לדוגמה: התקנת קו מים חם',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: BsTokens.space3),
              const _SecH('תיאור'),
              TextField(
                key: const ValueKey('author-detail'),
                controller: _detail,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'פרטי הביצוע (אופציונלי)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: BsTokens.space3),
              const _SecH('שלבי ביצוע — שלב בכל שורה'),
              TextField(
                key: const ValueKey('author-steps'),
                controller: _steps,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'כל שורה = שלב נפרד (אופציונלי)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: BsTokens.space3),
              const _SecH('משך משוער (ימים)'),
              TextField(
                key: const ValueKey('author-days'),
                controller: _days,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '1',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: BsTokens.space3),
              // 📅 GANTT (Wave G2b) — the optional planned-start date that lands
              // the task on the gantt timeline. Honest: shows the picked date or
              // 'לא נקבע' (never an invented date); null keeps it unscheduled.
              const _SecH('📅 תאריך התחלה (לגאנט)'),
              OutlinedButton.icon(
                key: const ValueKey('author-start'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: BsTokens.brandDark,
                  side: const BorderSide(color: BsTokens.brand, width: 1.5),
                  minimumSize: const Size(double.infinity, 48),
                  alignment: AlignmentDirectional.centerStart,
                  padding: const EdgeInsets.symmetric(
                    horizontal: BsTokens.space4,
                    vertical: 9,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                  ),
                ),
                onPressed: _pickStart,
                icon: const Icon(Icons.event, size: 18),
                label: Text(
                  _scheduledStart == null
                      ? 'לא נקבע'
                      : _fmtAuthorDate(_scheduledStart!),
                  style: const TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: BsTokens.space3),
              const _SecH('שיוך לעובד'),
              _WorkerPick(
                selected: _worker,
                onSelect: (i) => setState(() => _worker = i),
              ),
              const SizedBox(height: BsTokens.space4),
              _PrimaryBtn(
                key: const ValueKey('author-save'),
                label: _isEdit ? 'שמור שינויים' : 'צור משימה',
                onTap: _save,
              ),
              const SizedBox(height: BsTokens.space2),
              _PrimaryBtn(
                label: 'ביטול',
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
