import 'package:buildsmart/data/persona_data.dart';
import 'package:buildsmart/data/task_skus_local.dart';
import 'package:buildsmart/screens/barcode_scanner.dart';
import 'package:buildsmart/screens/chats_screen.dart';
import 'package:buildsmart/screens/lipskey_product_sheet.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/screens/worker_notifs_sheet.dart';
import 'package:buildsmart/screens/worker_profile_screen.dart';
import 'package:buildsmart/screens/worker_reports_tab.dart';
import 'package:buildsmart/screens/worker_settings_screen.dart';
import 'package:buildsmart/screens/worker_task_detail_sheet.dart';
import 'package:buildsmart/screens/worker_today_strip.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:buildsmart/state/worker_tasks_engine.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🦺 עובד — the field-worker BOARD. Same shell/style as the contractor app
/// (white AppBar + card list + the home_shell-style bottom tab bar); only the
/// content differs. The task cards/buckets are the faithful port of the
/// prototype `renderWorker()` (proto 06 §4.2) — minus the worker picker, which
/// is replaced by the real logged identity (#66).
///
/// 🔒 BOARD GATE (#66, חוק: מבחוץ לא רואים כלום): without a worker
/// [BoardSession] the build returns ONLY the registration gate
/// ([WelcomeScreen] in role mode) — no board content widget is constructed.
/// The logged worker (ran→רן · omer→עומר · demo→רן + 'דמו' chip) sees ONLY
/// their own tasks everywhere: queue, submitted, stats and reports.
///
/// TABS (#67): משימות (the board, default) · שיחות (worker-audience
/// [ChatsScreen], contract §3) · דוחות (submission history + live stats) ·
/// אזור אישי ([WorkerProfileScreen]).
///
/// LIVE (cross-persona W3, bridged): the board reads the rich [tasksProvider]
/// (verbatim detail/steps/photo — the §6 engine) and BRIDGES the legacy
/// [workerTasksProvider]: a worker submit writes BOTH engines (so the 👔
/// manager dashboard's approvals queue still picks it up live), and a manager
/// approve/reject there is mirrored back onto [tasksProvider] — reflecting
/// live here, exactly as before.
///
/// Reached from the role picker ("מי אתה?" → עובד). R8 — every string/number
/// is verbatim from the seeds (`persona_data.dart` / `phaseb_seeds.dart`).
class WorkerAppScreen extends ConsumerStatefulWidget {
  const WorkerAppScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const WorkerAppScreen());

  @override
  ConsumerState<WorkerAppScreen> createState() => _WorkerAppScreenState();
}

class _WorkerAppScreenState extends ConsumerState<WorkerAppScreen> {
  /// Active bottom tab — 0 משימות · 1 שיחות · 2 דוחות · 3 אזור אישי (#67).
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    // 🔒 BOARD GATE (#66, חוק: מבחוץ לא רואים כלום): without a worker session
    // ONLY the registration gate is built (the welcome screen in role mode) —
    // none of the board content widgets below are constructed. A login/demo on
    // the gate writes [boardAuthProvider] and this watch rebuilds into the
    // board.
    final session = ref.watch(boardAuthProvider);
    if (session == null || session.role != BoardRole.worker) {
      return const WelcomeScreen(boardRole: BoardRole.worker);
    }
    final worker = workerIndexForSession(session);

    // W3 BRIDGE — the manager dashboard still decides on the legacy
    // [workerTasksProvider]; mirror its review→done / review→rejected onto the
    // rich [tasksProvider] this board reads (via the engine's own existing
    // approve/reject calls) so a manager decision flips the card here live.
    // Post-frame so the mutation never lands mid-build; convergent (every call
    // moves a task out of `review`), so it cannot loop.
    final legacy = ref.watch(workerTasksProvider);
    final rich = ref.watch(tasksProvider);
    if (_needsMirror(legacy, rich)) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _mirrorManagerDecisions());
    }

    // #85ז first-pass log: remember every task ever seen `rejected` — the
    // engine keeps only the CURRENT status, so the reports tab needs this log
    // to compute אחוז אישור-ראשון across resubmits. Post-frame so the write
    // never lands mid-build; no-op when nothing is new (cannot loop).
    final rejLog = ref.watch(taskRejectionLogProvider);
    final newlyRejected = [
      for (final t in rich)
        if (t.status == 'rejected' && !rejLog.contains(t.id)) t.id,
    ];
    if (newlyRejected.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(taskRejectionLogProvider.notifier).recordAll(newlyRejected);
        }
      });
    }

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
            // 🔔 runtime notifications (#85ו) — unread badge + sheet, the
            // logged worker's own feed only (state/worker_notifs.dart).
            const WorkerNotifsBell(),
            // שיחות + פרופיל moved into the bottom tabs (#67). The gear opens
            // the WORKER-scoped settings (#69) — not the catalog settings.
            // '‹ יציאה' leaves the board screen; logging OUT lives in the
            // אזור-אישי tab (boardAuth logout → gate, #68).
            // 💡 מצב היכרות (#85ה) — the home_shell lightbulb reuse: flips
            // helpModeProvider, and the HelpTarget-wrapped board controls then
            // explain themselves in a bubble instead of acting.
            const HelpToggleButton(),
            // 📷 סרוק מוצר (#85ה) — see _scanProduct.
            HelpTarget(
              title: 'סריקת מוצר',
              body: 'פותח מצלמה לסריקת ברקוד או מק"ט. מוצר שנמצא בקטלוג '
                  'נפתח כאן בכרטיס המוצר המלא — כולל ערכת ההתקנה שלו.',
              child: IconButton(
                tooltip: 'סרוק מוצר',
                icon: const Icon(Icons.qr_code_scanner,
                    color: BsTokens.mutedLight),
                onPressed: _scanProduct,
              ),
            ),
            HelpTarget(
              title: 'הגדרות עובד',
              body: 'פותח את הגדרות הלוח המותאמות לעובד.',
              child: IconButton(
                tooltip: 'הגדרות',
                icon: const Icon(Icons.settings_outlined,
                    color: BsTokens.mutedLight),
                onPressed: () =>
                    Navigator.of(context).push(WorkerSettingsScreen.route()),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text(
                '‹ יציאה',
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 14),
              ),
            ),
          ],
        ),
        // #85ה: HelpModeScaffold shows the orange 'מצב היכרות' ribbon above the
        // tab body while help mode is on (the home_shell pattern, task #30).
        body: HelpModeScaffold(
          child: switch (_tab) {
            // 🔒 ISOLATION (SPEC §2.5): the chats tab embeds the worker-audience
            // ChatsScreen body (contract §3) — no route out of this board.
            1 => const ChatsScreen(
                persona: BsRole.worker,
                audience: 'worker',
              ),
            2 => WorkerReportsTab(worker: worker),
            3 => const WorkerProfileScreen(embedded: true),
            _ =>
              _TasksTab(worker: worker, demo: session.demo, onSubmit: _submit),
          },
        ),
        bottomNavigationBar: HelpTarget(
          title: 'טאבי הלוח',
          body: 'ארבעת אזורי הלוח: משימות — העבודה שלך; שיחות — קבלן, מנהל '
              'ובוט; דוחות — היסטוריית ההגשות; אזור אישי — פרופיל ויציאה.',
          child: _WorkerNav(
            currentIndex: _tab,
            onTap: (i) => setState(() => _tab = i),
          ),
        ),
      ),
    );
  }

  /// True when a manager decision on the legacy engine has not been mirrored
  /// onto the rich engine yet (same id still `review` here, decided there).
  bool _needsMirror(List<PersonaTask> legacy, List<TaskItem> rich) =>
      legacy.any((lt) {
        final match = rich.where((t) => t.id == lt.id);
        return match.isNotEmpty &&
            match.first.status == 'review' &&
            (lt.status == 'done' || lt.status == 'rejected');
      });

  /// Apply pending manager decisions through the rich engine's own
  /// approve/reject (no new state) — see the W3 BRIDGE note in [build].
  void _mirrorManagerDecisions() {
    if (!mounted) return;
    final legacy = ref.read(workerTasksProvider);
    final rich = ref.read(tasksProvider);
    final engine = ref.read(tasksProvider.notifier);
    for (final lt in legacy) {
      final match = rich.where((t) => t.id == lt.id);
      if (match.isEmpty || match.first.status != 'review') continue;
      if (lt.status == 'done') engine.approve(lt.id);
      if (lt.status == 'rejected') engine.reject(lt.id);
    }
  }

  /// WORKER submit — "שלח לאישור", routed through the ONE shared proof-photo
  /// path ([submitWithProofPhoto], worker_task_detail_sheet.dart): REAL
  /// capture → preview/confirm dialog → [TasksNotifier.attachPhoto] WITH the
  /// data-URL → the dual-engine submit (the W3 BRIDGE). The captured photo is
  /// therefore actually stored on the task — the manager sees it in the
  /// approvals queue. Cancel anywhere → honest toast inside the shared flow,
  /// NO submit. `Future<void> Function(TaskItem)` is assignable to the
  /// existing `void Function(TaskItem)` onSubmit callback, so no caller
  /// changes.
  Future<void> _submit(TaskItem task) async {
    await submitWithProofPhoto(context, ref, task);
  }

  /// 📷 סרוק מוצר (#85ה) — open the device scanner; an exact SKU match opens
  /// the product's REAL catalog sheet right here. The ai_hub flow routes a
  /// scanned code into the contractor catalog's live search — this board is
  /// ISOLATED (no route out, SPEC §2.5), so we resolve against the same
  /// unified catalog ([productBySku] over `kCatalogProducts`) and open the
  /// same [showLipskeyProductSheet] in place instead. No match → an honest
  /// toast, never a fake product.
  Future<void> _scanProduct() async {
    final code = await openBarcodeScanner(context);
    if (code == null || code.trim().isEmpty || !mounted) return;
    final product = productBySku(code);
    if (product == null) {
      showToast(context, 'לא נמצא מוצר בקטלוג עבור הקוד $code');
      return;
    }
    showLipskeyProductSheet(context, product, catalogSiblingsFor(product));
  }
}

/// Tab 1 — משימות: the board content (summary + the three buckets), scoped to
/// the LOGGED worker only (#66) over the live [tasksProvider].
class _TasksTab extends ConsumerWidget {
  const _TasksTab({
    required this.worker,
    required this.demo,
    required this.onSubmit,
  });

  final int worker;
  final bool demo;
  final void Function(TaskItem) onSubmit;

  /// Live tasks of [worker] whose status is in [statuses] — the bucket filter
  /// (current = active|rejected · queue = pending · submitted = review|done).
  List<TaskItem> _bucket(List<TaskItem> all, Set<String> statuses) => all
      .where((t) => t.worker == worker && statuses.contains(t.status))
      .toList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(tasksProvider);
    final mine = all.where((t) => t.worker == worker).toList();

    final current = _bucket(all, {'active', 'rejected'});
    final queue = _bucket(all, {'pending'});
    final submitted = _bucket(all, {'review', 'done'});
    final total = mine.length;
    final done = _bucket(all, {'done'}).length;
    final hasActive = _bucket(all, {'active'}).isNotEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        BsTokens.space4,
        BsTokens.space4,
        BsTokens.space4,
        BsTokens.space5,
      ),
      children: [
        // סדר-יום (#85ה): the worker's SmartProject day-plan strip — today's
        // stage + the next one, filtered to the logged worker (DayStage.worker
        // == the session's seed index). Honest empty line when none.
        WorkerTodayStrip(worker: worker),
        const SizedBox(height: BsTokens.space4),
        _SummaryCard(
          name: workerShortName(worker),
          demo: demo,
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
          header: current.isEmpty
              ? '🎉 אין משימה פעילה כרגע'
              : '🔨 המשימה הנוכחית שלך',
          tasks: current,
          // Only the current bucket (active/rejected) can be submitted.
          onSubmit: onSubmit,
        ),
        _Section(
          header: '⏳ הבאות בתור (${queue.length})',
          tasks: queue,
          emptyText: 'אין משימות בתור — משימות חדשות מהמנהל יופיעו כאן',
        ),
        _Section(
          header: '📋 שהגשת (${submitted.length})',
          tasks: submitted,
          emptyText: 'עוד לא הגשת משימות לאישור',
        ),
      ],
    );
  }
}

/// The board's bottom bar (#67) — the contractor home_shell tab-bar style
/// (white, fixed, brand selected).
class _WorkerNav extends StatelessWidget {
  const _WorkerNav({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFFFFFFFF),
      selectedItemColor: BsTokens.brand,
      unselectedItemColor: const Color(0xFF888888),
      selectedFontSize: 12,
      unselectedFontSize: 11,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.handyman_outlined),
          activeIcon: Icon(Icons.handyman),
          label: 'משימות',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          activeIcon: Icon(Icons.chat_bubble),
          label: 'שיחות',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          activeIcon: Icon(Icons.assignment),
          label: 'דוחות',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'אזור אישי',
        ),
      ],
    );
  }
}

/// Greeting + progress summary (`ww-summary`).
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.name,
    required this.demo,
    required this.done,
    required this.total,
    required this.activeCount,
    required this.queueCount,
    required this.submittedCount,
    required this.hasActive,
    required this.hasQueue,
  });

  final String name;

  /// Honest demo-session marker — a demo login enters as רן (#66).
  final bool demo;

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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'שלום, $name 👷',
                            style: const TextStyle(
                              color: BsTokens.inkLight,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        if (demo) ...[
                          const SizedBox(width: BsTokens.space2),
                          // Honest 'דמו' chip (#66) — a demo session enters as רן.
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F3F5),
                              borderRadius:
                                  BorderRadius.circular(BsTokens.radiusPill),
                            ),
                            child: const Text(
                              'דמו',
                              style: TextStyle(
                                color: BsTokens.mutedLight,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
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
  const _Section({
    required this.header,
    required this.tasks,
    this.onSubmit,
    this.emptyText,
  });

  final String header;
  final List<TaskItem> tasks;
  final void Function(TaskItem)? onSubmit;

  /// Shown instead of the cards when [tasks] is empty. Optional — the current
  /// section's header already says "אין משימה פעילה" so it passes nothing.
  final String? emptyText;

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
        if (tasks.isEmpty && emptyText != null)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
                BsTokens.space1, 0, BsTokens.space1, BsTokens.space2),
            child: Text(
              emptyText!,
              style: const TextStyle(
                color: BsTokens.mutedLight,
                fontSize: 13.5,
              ),
            ),
          )
        else
          for (final t in tasks)
            HelpTarget(
              title: 'כרטיס משימה',
              body: 'לחיצה על הכרטיס פותחת את פירוט המשימה — שלבים, הוראות, '
                  '"מה להביא" ודיווח ביצוע. כפתור "שלח לאישור" מגיש את '
                  'המשימה לאישור המנהל.',
              child: _TaskCard(task: t, onSubmit: onSubmit),
            ),
      ],
    );
  }
}

/// ⏱️ The task-clock line (#85ו) for a card, from its bs.task-clock.v1 entry
/// ([TaskClockEntry], worker_reports_tab.dart): a measured start→approval pair
/// → '⏱️ זמן עבודה: …'; a started-but-unfinished task → '⏱️ בעבודה מאז HH:MM';
/// no stamps (or an unordered pair) → null, and the card shows no line.
String? _taskClockLabel(TaskClockEntry? clock) {
  if (clock == null) return null;
  final d = clock.duration;
  if (d != null) return '⏱️ זמן עבודה: ${_fmtClockDuration(d)}';
  final s = clock.startedAt;
  if (s != null && clock.completedAt == null) {
    final hh = s.hour.toString().padLeft(2, '0');
    final mm = s.minute.toString().padLeft(2, '0');
    return '⏱️ בעבודה מאז $hh:$mm';
  }
  return null;
}

/// Compact Hebrew duration for the task-clock line.
String _fmtClockDuration(Duration d) {
  if (d.inMinutes < 1) return 'פחות מדקה';
  if (d.inHours < 1) return '${d.inMinutes} דק׳';
  if (d.inDays < 1) {
    final m = d.inMinutes % 60;
    return m == 0 ? '${d.inHours} שע׳' : '${d.inHours} שע׳ $m דק׳';
  }
  final h = d.inHours % 24;
  return h == 0 ? '${d.inDays} ימים' : '${d.inDays} ימים $h שע׳';
}

/// A single task, in the app's card style (white rounded card). Tapping the
/// card opens the full detail sheet (#71 — real steps/instructions/photo).
/// When [onSubmit] is provided AND the task is in a submittable status
/// (`active`/`rejected`), a "שלח לאישור" button is shown that calls it.
class _TaskCard extends ConsumerWidget {
  const _TaskCard({required this.task, this.onSubmit});

  final TaskItem task;
  final void Function(TaskItem)? onSubmit;

  /// Submittable = a worker-owned status the manager has not yet seen.
  bool get _canSubmit =>
      onSubmit != null && (task.status == 'active' || task.status == 'rejected');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ⏱️ task clock (#85ו) — read-only view of the bs.task-clock.v1 side-map
    // (see worker_reports_tab.dart; the writer lives with the engine). No
    // stamp for this task → no line: honest, no invented times.
    final clock = ref.watch(taskClockProvider).asData?.value[task.id];
    return Padding(
      padding: const EdgeInsets.only(bottom: BsTokens.space2),
      child: Material(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        elevation: 1,
        shadowColor: Colors.black26,
        child: InkWell(
          // #71: any task card opens its detail sheet (steps/הוראות/תמונה).
          borderRadius: BorderRadius.circular(BsTokens.radiusCard),
          onTap: () => showWorkerTaskDetailSheet(context, taskId: task.id),
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
                  '🕒 ${task.days} ימים · ${task.steps.length} שלבים',
                  style: const TextStyle(
                    color: BsTokens.mutedLight,
                    fontSize: 13,
                  ),
                ),
                // ⏱️ task clock (#85ו) — only once the engine stamped it
                // (started-only → 'בעבודה מאז', both stamps → the duration).
                if (_taskClockLabel(clock) != null) ...[
                  const SizedBox(height: BsTokens.space1),
                  Text(
                    _taskClockLabel(clock)!,
                    style: const TextStyle(
                      color: BsTokens.mutedLight,
                      fontSize: 12.5,
                    ),
                  ),
                ],
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
      // excludeSemantics — the inner Text equals the label (F-50).
      excludeSemantics: true,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Material(
          color: BsTokens.brand,
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          child: InkWell(
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: BsTokens.space4,
                vertical: 9,
              ),
              child: Text(
                '📸 שלח לאישור',
                style: TextStyle(
                  color: bsOnAccent(context),
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
