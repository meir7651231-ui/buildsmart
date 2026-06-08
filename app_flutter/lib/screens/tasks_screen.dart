// משימות SCREEN (T3.A · proto §6 [L8023-8200]) — the full team-tasks view with
// the manager/worker role toggle, the status buckets, the task-detail sheet
// (worker reports / manager approves), and the daily work-log sheet. All state
// is the live `tasksProvider` (5-state machine + auto-advance, see
// state/tasks_engine.dart). Style matches worker_app_screen.dart (white AppBar +
// card list). Every string/number verbatim from the prototype (R6/R8).
//
// Entry: openTasks (the leaf action) → TasksScreen.route().

import 'package:buildsmart/data/persona_data.dart';
import 'package:buildsmart/data/phaseb_seeds.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  String _role = 'manager'; // proto `taskRole='manager'`
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
            _RolePicker(
              role: _role,
              onSelect: (r) => setState(() => _role = r),
            ),
            const SizedBox(height: BsTokens.space3),
            if (_role == 'manager')
              ..._managerView(tasks)
            else
              ..._workerView(tasks),
          ],
        ),
      ),
    );
  }

  // ── MANAGER view (proto :8068-8081) ──────────────────────────────────────
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
      _LogButton(onTap: () => _openWorkLog(context)),
      if (review.isNotEmpty)
        _Group('📸 ממתין לאישור שלך (${review.length})', review, _open),
      if (active.isNotEmpty)
        _Group('🔨 בביצוע עכשיו (${active.length})', active, _open),
      if (pending.isNotEmpty)
        _Group('⏳ ממתינות בתור (${pending.length})', pending, _open),
      if (done.isNotEmpty)
        _Group('✅ הושלמו ואושרו (${done.length})', done, _open),
    ];
  }

  // ── WORKER view (proto :8082-8094) ───────────────────────────────────────
  List<Widget> _workerView(List<TaskItem> tasks) {
    final mine = tasks.where((t) => t.worker == _worker).toList();
    final current = mine
        .where((t) => t.status == 'active' || t.status == 'rejected')
        .toList();
    final queue = mine.where((t) => t.status == 'pending').toList();
    final submitted = mine
        .where((t) => t.status == 'review' || t.status == 'done')
        .toList();
    return [
      const _Intro(
        'בחר עובד כדי לראות את המשימות שלו (בהדגמה — באפליקציה אמיתית כל עובד מחובר לחשבון שלו).',
      ),
      const SizedBox(height: BsTokens.space2),
      _WorkerPick(selected: _worker, onSelect: (i) => setState(() => _worker = i)),
      if (current.isNotEmpty)
        _Group('🔨 המשימה הנוכחית שלך', current, _open)
      else
        const _DoneAll('🎉 אין משימה פעילה כרגע'),
      if (queue.isNotEmpty) _Group('⏳ הבאות בתור (${queue.length})', queue, _open),
      if (submitted.isNotEmpty)
        _Group('📋 שהגשת (${submitted.length})', submitted, _open),
    ];
  }

  void _open(TaskItem t) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _TaskSheet(task: t, role: _role),
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
}

// ── role / worker pickers ───────────────────────────────────────────────────
class _RolePicker extends StatelessWidget {
  const _RolePicker({required this.role, required this.onSelect});
  final String role;
  final void Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    Widget btn(String key, String label) => Expanded(
          child: Material(
            color: role == key ? BsTokens.brand : BsTokens.cardLight,
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
            child: InkWell(
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
              onTap: () => onSelect(key),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: BsTokens.space3),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: role == key ? bsOnAccent(context) : BsTokens.inkLight,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        );
    return Row(children: [
      btn('manager', '👔 מנהל'),
      const SizedBox(width: BsTokens.space2),
      btn('worker', '🦺 עובד'),
    ]);
  }
}

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
                    kWorkers[i],
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
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        elevation: 1,
        shadowColor: Colors.black26,
        child: InkWell(
          borderRadius: BorderRadius.circular(BsTokens.radiusCard),
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
  const _Group(this.header, this.tasks, this.onTap);
  final String header;
  final List<TaskItem> tasks;
  final void Function(TaskItem) onTap;

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
        for (final t in tasks) _Card(task: t, onTap: () => onTap(t)),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.task, required this.onTap});
  final TaskItem task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BsTokens.space2),
      child: Material(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        elevation: 1,
        shadowColor: Colors.black26,
        child: InkWell(
          key: ValueKey('task-${task.id}'),
          borderRadius: BorderRadius.circular(BsTokens.radiusCard),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(BsTokens.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F3F5),
                    borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                  ),
                  child: Text(
                    kTaskStatusLabel[task.status] ?? '',
                    style: const TextStyle(
                        color: BsTokens.inkLight,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5),
                  ),
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
                  '👷 ${kWorkers[task.worker]} · 📋 ${task.steps.length} שלבים · ⏱️ ${task.days} ימים',
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
              Text('👷 ${kWorkers[t.worker]}',
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
                Container(
                  padding: const EdgeInsets.all(BsTokens.space4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F3F5),
                    borderRadius: BorderRadius.circular(BsTokens.radiusCard),
                  ),
                  child: Text('📷 תמונה מהשטח — ${kWorkers[t.worker]}',
                      style: const TextStyle(
                          color: BsTokens.mutedLight, fontSize: 13)),
                ),
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
                  onPressed: () {
                    ref.read(tasksProvider.notifier).attachPhoto(t.id);
                    showToast(context, 'תמונה צורפה (הדגמה)');
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
                      onPressed: () {
                        ref.read(tasksProvider.notifier).reject(t.id);
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
                      onTap: () {
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
