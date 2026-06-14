import 'package:buildsmart/data/persona_data.dart';
import 'package:buildsmart/data/task_skus_local.dart';
import 'package:buildsmart/screens/barcode_scanner.dart';
import 'package:buildsmart/screens/chats_screen.dart';
import 'package:buildsmart/screens/docs_readiness_gate.dart';
import 'package:buildsmart/screens/lipskey_product_sheet.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/screens/worker_attendance_screen.dart';
import 'package:buildsmart/screens/worker_equipment_checklist_sheet.dart';
import 'package:buildsmart/screens/worker_notifs_sheet.dart';
import 'package:buildsmart/screens/worker_profile_screen.dart';
import 'package:buildsmart/screens/worker_reports_tab.dart';
import 'package:buildsmart/screens/worker_settings_screen.dart';
import 'package:buildsmart/screens/worker_task_board_screen.dart';
import 'package:buildsmart/screens/worker_task_detail_sheet.dart';
import 'package:buildsmart/screens/worker_today_strip.dart';
import 'package:buildsmart/services/geo.dart';
import 'package:buildsmart/services/nav_launch.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/docs_readiness.dart';
import 'package:buildsmart/state/smart_project_engine.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:buildsmart/state/worker_attendance.dart';
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
/// LIVE (cross-persona W3): the board reads the single unified [tasksProvider]
/// (verbatim detail/steps/photo — the §6 engine). Wave T1 collapsed the old
/// dual-engine bridge into ONE source of truth: a worker submit and the 👔
/// manager dashboard's approve/reject all run on this same engine, so each
/// reflects live on the other with no reconcile.
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

    // 🔒 #101 — שער-מוכנות מסמכים (HARD gate): immediately after the role-gate,
    // block the board until the logged worker's documents are complete +
    // in-date (signed current-year 101 + no expired cert; see
    // [workerDocsReadiness]). The decision is LIVE — signing the 101 / adding a
    // valid cert via the gate's deep-links re-evaluates and opens the board.
    // [docsGateOverrideProvider] is the TEST SEAM: non-null forces the decision
    // (board tests set true to bypass this gate). Sits ABOVE the journal-home
    // below — none of it is disturbed.
    final ov = ref.watch(docsGateOverrideProvider);
    final r = ref.watch(workerDocsReadyProvider(session.username));
    final ready = ov ?? r.ready;
    if (!ready) {
      return DocsReadinessGate(role: BoardRole.worker, readiness: r);
    }

    final worker = workerIndexForSession(session);

    // One source of truth (Wave T1): the manager dashboard now decides on the
    // SAME unified [tasksProvider] this board reads, so a manager review→done /
    // review→rejected flips the card here live with no reconcile — the old
    // legacy-engine mirror is gone.
    final rich = ref.watch(tasksProvider);

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
            // 🗂️ לוח משימות מלא (#114) — the status-GROUPED hierarchical board
            // of ALL this worker's tasks (each row dives into the #71 detail
            // sheet). An app-bar action so it sits outside the tasks ListView
            // and disturbs none of the journal's layout/scroll order.
            HelpTarget(
              title: 'לוח משימות מלא',
              body: 'פותח לוח של כל המשימות שלך מקובצות לפי מצב — פעילות, '
                  'בתור, בבדיקה והושלמו — עם פס-התקדמות וצלילה לכל משימה.',
              child: IconButton(
                tooltip: 'לוח משימות מלא',
                icon: const Icon(Icons.dashboard_outlined,
                    color: BsTokens.mutedLight),
                onPressed: () =>
                    Navigator.of(context).push(WorkerTaskBoardScreen.route()),
              ),
            ),
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
            _ => _TasksTab(
                worker: worker,
                username: session.username,
                demo: session.demo,
                onSubmit: _submit,
              ),
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

  /// WORKER submit — "שלח לאישור", routed through the ONE shared proof-photo
  /// path ([submitWithProofPhoto], worker_task_detail_sheet.dart): REAL
  /// capture → preview/confirm dialog → [TasksNotifier.attachPhoto] WITH the
  /// data-URL → the unified [tasksProvider] submit (stamping the acting
  /// session's identity). The captured photo is therefore actually stored on
  /// the task — the manager sees it in the approvals queue. Cancel anywhere →
  /// honest toast inside the shared flow, NO submit. `Future<void>
  /// Function(TaskItem)` is assignable to the existing `void Function(TaskItem)`
  /// onSubmit callback, so no caller changes.
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

/// Tab 1 — משימות, now a JOURNAL (#113+#100): the home tab opens on a
/// week-strip with TODAY pre-pressed, days that carry attendance/work marked
/// with a dot. Below the selected day: that day's נוכחות + מיקום (the location
/// row launches [openNavSheet], contract 3) + a clock-with-GPS button on TODAY
/// (contract 4) + that day's tasks from the live [tasksProvider] (cards that
/// dive into the detail sheet, #71). 'חודש מלא' routes to the full monthly
/// attendance calendar ([WorkerAttendanceScreen], #105). Everything is scoped
/// to the LOGGED worker only (#66). 🔁 ONLY this home tab changed — the other
/// three board tabs are untouched.
class _TasksTab extends ConsumerStatefulWidget {
  const _TasksTab({
    required this.worker,
    required this.username,
    required this.demo,
    required this.onSubmit,
  });

  final int worker;

  /// Board login username — the attendance ledger's identity key (#66).
  final String username;
  final bool demo;
  final void Function(TaskItem) onSubmit;

  @override
  ConsumerState<_TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends ConsumerState<_TasksTab> {
  /// The journal's selected day — pre-pressed on TODAY at first entry (#113).
  /// Date-only (midnight) so day-key comparisons are exact.
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selected = DateTime(now.year, now.month, now.day);
  }

  /// Live tasks of the logged worker whose status is in [statuses] — the bucket
  /// filter (current = active|rejected · queue = pending · submitted =
  /// review|done).
  List<TaskItem> _bucket(List<TaskItem> all, Set<String> statuses) => all
      .where((t) =>
          t.worker == widget.worker && statuses.contains(t.status))
      .toList();

  bool get _selectedIsToday {
    final now = DateTime.now();
    return _selected.year == now.year &&
        _selected.month == now.month &&
        _selected.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(tasksProvider);
    final mine = all.where((t) => t.worker == widget.worker).toList();

    final current = _bucket(all, {'active', 'rejected'});
    final queue = _bucket(all, {'pending'});
    final submitted = _bucket(all, {'review', 'done'});
    final total = mine.length;
    final done = _bucket(all, {'done'}).length;
    final hasActive = _bucket(all, {'active'}).isNotEmpty;

    // Attendance ledger of the logged worker (#66) — drives the week-strip dots
    // and the selected-day נוכחות/מיקום panel.
    final ledger = ref.watch(workerAttendanceProvider);
    final selectedDay = _attendanceFor(ledger, _selected);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        BsTokens.space4,
        BsTokens.space4,
        BsTokens.space4,
        BsTokens.space5,
      ),
      children: [
        // 📅 JOURNAL (#113) — the week strip, TODAY pre-pressed; a day with
        // attendance OR a planned work-stage carries a dot.
        _WeekStripCard(
          selected: _selected,
          username: widget.username,
          worker: widget.worker,
          onSelect: (d) => setState(() => _selected = d),
          onFullMonth: () =>
              Navigator.of(context).push(WorkerAttendanceScreen.route()),
        ),
        const SizedBox(height: BsTokens.space4),
        // נוכחות + מיקום של היום-הנבחר (#113). On TODAY the clock-with-GPS
        // button (contract 4) is live; on a past day the panel is a read-only
        // summary. The location row launches the nav sheet (contract 3).
        _DayAttendanceCard(
          day: selectedDay,
          isToday: _selectedIsToday,
          onClock: _selectedIsToday ? _clockWithGps : null,
          onOpenLocation: () => _openDayLocation(selectedDay),
        ),
        const SizedBox(height: BsTokens.space4),
        // סדר-יום (#85ה): the worker's SmartProject day-plan strip — today's
        // stage + the next one, filtered to the logged worker. Kept as the
        // journal's plan context. Honest empty line when none.
        WorkerTodayStrip(worker: widget.worker),
        const SizedBox(height: BsTokens.space4),
        _SummaryCard(
          name: workerShortName(widget.worker),
          demo: widget.demo,
          done: done,
          total: total,
          activeCount: hasActive ? 1 : 0,
          queueCount: queue.length,
          submittedCount: submitted.length,
          hasActive: hasActive,
          hasQueue: queue.isNotEmpty,
        ),
        const SizedBox(height: BsTokens.space4),
        // משימות-היום (#113) — the live buckets from [tasksProvider], cards
        // that dive into the detail sheet (#71, chevron). HONEST framing: the
        // §6 tasks carry no calendar date, so these are the worker's CURRENT
        // live tasks shown under the selected day — not a per-day history.
        _Section(
          header: current.isEmpty
              ? '🎉 אין משימה פעילה כרגע'
              : '🔨 המשימה הנוכחית שלך',
          tasks: current,
          // Only the current bucket (active/rejected) can be submitted.
          onSubmit: widget.onSubmit,
        ),
        // 🧰 בדוק ציוד נדרש (#112) — aggregate the equipment checklist for the
        // worker's CURRENT bucket (active/rejected) via Builder-B's sheet. Only
        // shown when there is a current task, so it never offers an empty
        // checklist. Placed under the current section, above the queue header —
        // the queue/submitted headers keep their order (reached by scroll).
        if (current.isNotEmpty)
          _EquipmentButton(
            onPressed: () =>
                showEquipmentChecklistSheet(context, ref, tasks: current),
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

  /// The logged worker's [AttendanceDay] for [day], or null when none.
  AttendanceDay? _attendanceFor(List<AttendanceDay> ledger, DateTime day) {
    final key = attendanceDateKey(day);
    for (final d in ledger) {
      if (d.username == widget.username && d.date == key) return d;
    }
    return null;
  }

  /// clock-with-GPS (contract 4) — read a real fix (null on deny/error/native
  /// stub, NEVER an invented coordinate), then clock in/out for TODAY carrying
  /// the fix's lat/lng. No fix → record attendance with NO location + the
  /// honest toast. One shift per day: the notifier is state-guarded.
  Future<void> _clockWithGps() async {
    final notifier = ref.read(workerAttendanceProvider.notifier);
    final today = notifier.todayFor(widget.username);
    final clockingOut = today != null && today.outTs == null;

    final fix = await currentGeoFix();
    if (!mounted) return;

    final bool ok;
    if (clockingOut) {
      ok = notifier.clockOut(widget.username, lat: fix?.lat, lng: fix?.lng);
    } else {
      ok = notifier.clockIn(widget.username, lat: fix?.lat, lng: fix?.lng);
    }

    if (!ok) {
      showToast(
        context,
        clockingOut ? 'אין כניסה פתוחה להיום' : 'כבר נרשמה כניסה להיום',
      );
      return;
    }
    if (fix == null) {
      // Honest: attendance recorded, but no location captured (contract 4).
      showToast(context, 'מיקום לא זמין — נרשמה נוכחות בלי מיקום');
      return;
    }
    showToast(
      context,
      clockingOut ? '🔴 נרשמה יציאה עם מיקום' : '🟢 נרשמה כניסה עם מיקום',
    );
  }

  /// מיקום-לחיץ (contract 3) — open the internal nav sheet for the selected
  /// day's clock-in coordinate. Honest toast when the day has no location.
  void _openDayLocation(AttendanceDay? day) {
    final query = day == null ? null : mapsQueryForDay(day);
    if (day == null || query == null) {
      showToast(context, 'אין מיקום שמור ליום זה');
      return;
    }
    openNavSheet(
      context,
      label: 'מיקום העבודה · ${_fmtJournalDate(_selected)}',
      lat: day.inLat,
      lng: day.inLng,
    );
  }
}

/// 📅 The week-strip journal card (#113) — seven day-chips ending on TODAY,
/// the selected day highlighted (TODAY pre-pressed at first entry). A day with
/// attendance OR a planned SmartProject day-stage carries a dot. 'חודש מלא'
/// routes to the full monthly calendar (#105).
class _WeekStripCard extends ConsumerWidget {
  const _WeekStripCard({
    required this.selected,
    required this.username,
    required this.worker,
    required this.onSelect,
    required this.onFullMonth,
  });

  final DateTime selected;
  final String username;
  final int worker;
  final void Function(DateTime) onSelect;
  final VoidCallback onFullMonth;

  /// Hebrew single-letter weekday initials, Sunday-first (DateTime.sunday == 7).
  static const List<String> _wd = ['א', 'ב', 'ג', 'ד', 'ה', 'ו', 'ש'];

  String _wdLabel(DateTime d) => _wd[d.weekday % 7];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // The seven days ending on today (today is the last/rightmost in RTL flow,
    // rendered start→end so the oldest is first).
    final days = [for (var i = 6; i >= 0; i--) today.subtract(Duration(days: i))];

    // Day-keys with attendance for this worker (a dot source).
    final ledger = ref.watch(workerAttendanceProvider);
    final attDays = {
      for (final d in ledger)
        if (d.username == username) d.date,
    };
    // Day-keys that fall on a planned SmartProject day-stage for this worker —
    // the journal's second dot source. The §7 plan carries no calendar dates,
    // so a planned stage marks TODAY only (the plan's "היום"); honest, no
    // invented per-day mapping.
    final hasPlan = buildDayStages().any((s) => s.worker == worker);
    final todayKey = attendanceDateKey(today);

    bool hasDot(DateTime d) {
      final key = attendanceDateKey(d);
      if (attDays.contains(key)) return true;
      return hasPlan && key == todayKey;
    }

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
              const Expanded(
                child: Text(
                  '📅 היומן שלי',
                  style: TextStyle(
                    color: BsTokens.inkLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              HelpTarget(
                title: 'חודש מלא',
                body: 'פותח את לוח-הנוכחות החודשי המלא — כניסה/יציאה, מיקום '
                    'וסיכום-עבודה לכל יום בחודש.',
                child: Semantics(
                  button: true,
                  label: 'חודש מלא',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                    onTap: onFullMonth,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: BsTokens.space3,
                        vertical: 10,
                      ),
                      child: Text(
                        'חודש מלא ›',
                        style: TextStyle(
                          color: BsTokens.brandDark,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: BsTokens.space2),
          Row(
            children: [
              for (final d in days)
                Expanded(
                  child: _DayChip(
                    label: _wdLabel(d),
                    dayNum: d.day,
                    selected: _sameDay(d, selected),
                    isToday: _sameDay(d, today),
                    hasDot: hasDot(d),
                    onTap: () => onSelect(d),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

/// One day-chip in the week strip — weekday initial + day number, with the
/// attendance/work dot and the selected/today emphasis. ≥48dp tap target.
class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.dayNum,
    required this.selected,
    required this.isToday,
    required this.hasDot,
    required this.onTap,
  });

  final String label;
  final int dayNum;
  final bool selected;
  final bool isToday;
  final bool hasDot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fill = selected ? BsTokens.brand : Colors.transparent;
    final numColor = selected ? bsOnAccent(context) : BsTokens.inkLight;
    return Semantics(
      button: true,
      selected: selected,
      label: 'יום $label $dayNum${isToday ? ' · היום' : ''}',
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: selected ? BsTokens.brandDark : BsTokens.mutedLight,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: fill,
                  shape: BoxShape.circle,
                  border: isToday && !selected
                      ? Border.all(color: BsTokens.brand, width: 1.5)
                      : null,
                ),
                child: Text(
                  '$dayNum',
                  style: TextStyle(
                    color: numColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // The attendance/work dot — a tiny brand dot, or an invisible
              // spacer so chips keep one height.
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: hasDot
                      ? (selected ? BsTokens.brandDark : BsTokens.brand)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// נוכחות + מיקום של היום-הנבחר (#113). On TODAY ([isToday]) the big
/// clock-with-GPS action ([onClock], contract 4) is live; on a past day the
/// panel is a read-only summary. The location row launches the nav sheet
/// ([onOpenLocation], contract 3) when the day carries a coordinate.
class _DayAttendanceCard extends StatelessWidget {
  const _DayAttendanceCard({
    required this.day,
    required this.isToday,
    required this.onClock,
    required this.onOpenLocation,
  });

  final AttendanceDay? day;
  final bool isToday;

  /// clock-with-GPS — null on a past day (read-only).
  final VoidCallback? onClock;
  final VoidCallback onOpenLocation;

  @override
  Widget build(BuildContext context) {
    final inTs = day?.inTs;
    final outTs = day?.outTs;
    final worked = day?.worked;
    final hasLocation = day != null && mapsQueryForDay(day!) != null;

    // The clock action label mirrors the attendance screen's state machine:
    // כניסה (no open shift) → יציאה (clocked in) → done (one shift/day).
    final String? clockLabel;
    final Color clockColor;
    if (inTs == null) {
      clockLabel = '🟢 כניסה עם מיקום';
      clockColor = BsTokens.success;
    } else if (outTs == null) {
      clockLabel = '🔴 יציאה עם מיקום';
      clockColor = BsTokens.danger;
    } else {
      clockLabel = null; // day complete
      clockColor = const Color(0xFFE9EAEC);
    }

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
            isToday ? '🕐 נוכחות היום' : '🕐 נוכחות',
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: BsTokens.space3),
          Row(
            children: [
              _DayStat(label: 'כניסה', value: inTs == null ? '—' : _fmtTime(inTs)),
              _DayStat(
                  label: 'יציאה', value: outTs == null ? '—' : _fmtTime(outTs)),
              _DayStat(
                label: 'סה"כ',
                value: worked == null ? '—' : _fmtDur(worked),
              ),
            ],
          ),
          const SizedBox(height: BsTokens.space3),
          // 📍 מיקום-לחיץ (contract 3) — the day's clock-in coordinate opens
          // the internal nav sheet (Waze / Google Maps). Honest empty row when
          // no location was captured.
          HelpTarget(
            title: 'מיקום העבודה',
            body: 'נשמר ממכשיר ה-GPS בעת רישום הכניסה. לחיצה פותחת ניווט '
                'ב-Waze או ב-Google Maps אל מיקום העבודה.',
            child: Semantics(
              button: hasLocation,
              label: hasLocation ? 'פתח ניווט למיקום העבודה' : 'אין מיקום שמור',
              excludeSemantics: true,
              child: InkWell(
                borderRadius: BorderRadius.circular(BsTokens.radiusCard),
                onTap: hasLocation ? onOpenLocation : null,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 48),
                  padding: const EdgeInsets.symmetric(
                    horizontal: BsTokens.space3,
                    vertical: BsTokens.space2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(BsTokens.radiusCard),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 20,
                        color:
                            hasLocation ? BsTokens.brandDark : BsTokens.mutedLight,
                      ),
                      const SizedBox(width: BsTokens.space2),
                      Expanded(
                        child: Text(
                          hasLocation
                              ? 'מיקום העבודה נשמר — פתח ניווט'
                              : 'לא נשמר מיקום ליום זה',
                          style: TextStyle(
                            color: hasLocation
                                ? BsTokens.inkLight
                                : BsTokens.mutedLight,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (hasLocation)
                        const Icon(
                          Icons.chevron_left,
                          size: 22,
                          color: BsTokens.mutedLight,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (isToday && clockLabel != null) ...[
            const SizedBox(height: BsTokens.space3),
            HelpTarget(
              title: 'נוכחות עם מיקום',
              body: 'רושם כניסה/יציאה להיום ושומר את מיקום ה-GPS. אם המיקום '
                  'אינו זמין — הנוכחות נרשמת בלי מיקום, בלי המצאה.',
              child: Semantics(
                button: true,
                label: clockLabel,
                excludeSemantics: true,
                child: Material(
                  color: clockColor,
                  borderRadius: BorderRadius.circular(BsTokens.radiusCard),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(BsTokens.radiusCard),
                    onTap: onClock,
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 56),
                      alignment: Alignment.center,
                      child: Text(
                        clockLabel,
                        style: TextStyle(
                          color: bsOnAccent(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ] else if (isToday) ...[
            const SizedBox(height: BsTokens.space3),
            // Day complete — honestly disabled (one shift per day).
            Container(
              constraints: const BoxConstraints(minHeight: 48),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFE9EAEC),
                borderRadius: BorderRadius.circular(BsTokens.radiusCard),
              ),
              child: const Text(
                '✓ נרשמה נוכחות להיום',
                style: TextStyle(
                  color: BsTokens.mutedLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ] else if (inTs == null) ...[
            const SizedBox(height: BsTokens.space2),
            // Honest empty state for a past day with no attendance record.
            const Text(
              'לא נרשמה נוכחות ביום זה',
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

/// One נוכחות stat (כניסה/יציאה/סה"כ) in the selected-day panel.
class _DayStat extends StatelessWidget {
  const _DayStat({required this.label, required this.value});

  final String label;
  final String value;

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
              fontSize: 17,
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

/// `HH:MM` of a local instant — the journal's time format (mirrors the
/// attendance screen's own private formatter; kept file-local here).
String _fmtTime(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// Compact `H:MM` worked-hours label for the selected-day total.
String _fmtDur(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes % 60;
  return '$h:${m.toString().padLeft(2, '0')}';
}

/// `d.M` short date for the nav-sheet label of the selected journal day.
String _fmtJournalDate(DateTime d) => '${d.day}.${d.month}';

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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
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
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // #113 chevron-צלילה — the visible dive affordance into the
                    // task's detail sheet (RTL: chevron_left points "into").
                    const Icon(
                      Icons.chevron_left,
                      size: 22,
                      color: BsTokens.mutedLight,
                    ),
                  ],
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

/// 🧰 בדוק ציוד נדרש (#112) — a secondary (outlined) action under the current
/// bucket that opens Builder-B's aggregated equipment checklist sheet for the
/// worker's active/rejected tasks. Outlined (not a brand fill) so it reads as
/// secondary to the per-task 'שלח לאישור' pill and never competes with it.
/// ≥48dp; excludeSemantics — the inner Text equals the label.
class _EquipmentButton extends StatelessWidget {
  const _EquipmentButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: BsTokens.space2),
      child: HelpTarget(
        title: 'בדוק ציוד נדרש',
        body: 'מרכז את כל הכלים והחומרים הדרושים למשימות הפעילות שלך לרשימה '
            'אחת — צ\'קליסט מאוגד ליום, שאפשר לסמן ולשלוח לקבלן.',
        child: Semantics(
          button: true,
          label: 'בדוק ציוד נדרש',
          excludeSemantics: true,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: BsTokens.brandDark,
                side: const BorderSide(color: BsTokens.brand, width: 1.5),
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(
                  horizontal: BsTokens.space4,
                  vertical: 9,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                ),
              ),
              onPressed: onPressed,
              icon: const Text('🧰', style: TextStyle(fontSize: 15)),
              label: const Text(
                'בדוק ציוד נדרש',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
              ),
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
