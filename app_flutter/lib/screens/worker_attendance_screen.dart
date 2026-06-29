import 'package:buildsmart/data/persona_data.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/screens/worker_profile_screen.dart';
import 'package:buildsmart/services/geo.dart';
import 'package:buildsmart/services/nav_launch.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:buildsmart/state/worker_attendance.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/config_theme.dart' show cfgRadius;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🕐 נוכחות (#105) — the worker's clock-in/out screen rebuilt around a FULL
/// monthly CALENDAR GRID. The big state-aware כניסה/יציאה button now captures a
/// GPS fix (contract 4: [currentGeoFix] → [WorkerAttendanceNotifier.clockIn]
/// with lat/lng; null fix → honest "נרשמה נוכחות בלי מיקום"). Each calendar
/// cell shows the day's נוכחות at a glance; tapping a populated day opens a
/// detail sheet with כניסה/יציאה+סה"כ, a CLICKABLE location (contract 3:
/// [openNavSheet] → Waze / Google Maps), and an HONEST per-day work summary
/// derived from [tasksProvider] (which tasks were done/advanced that calendar
/// day, matched by the task clock's completedAt/startedAt — the engine carries
/// no separate completion-date stamp, so the day is derived from those
/// timestamps and labeled honestly). Month navigation blocks the future. Days
/// with no data render as honest empty cells / empty-state lines.
///
/// 'שלח דוח נוכחות לקבלן' posts an honest summary line into the
/// worker↔contractor chat thread (the board's existing report channel).
///
/// Data: [workerAttendanceProvider] (bs.worker-attendance.v1) — on-device, per
/// logged username. SERVER-SWAP: server attendance ledger later.
class WorkerAttendanceScreen extends ConsumerStatefulWidget {
  const WorkerAttendanceScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const WorkerAttendanceScreen());

  @override
  ConsumerState<WorkerAttendanceScreen> createState() =>
      _WorkerAttendanceScreenState();
}

class _WorkerAttendanceScreenState
    extends ConsumerState<WorkerAttendanceScreen> {
  /// First day of the month the calendar shows — starts on the current month.
  late DateTime _month;

  /// Months ('yyyy-MM') whose report was already sent this session — the
  /// double-tap guard (F-38): a second tap cannot post a duplicate report.
  final Set<String> _sentMonths = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  String get _monthKey => '${_month.year.toString().padLeft(4, '0')}-'
      '${_month.month.toString().padLeft(2, '0')}';

  bool get _viewingCurrentMonth {
    final now = DateTime.now();
    return _month.year == now.year && _month.month == now.month;
  }

  @override
  Widget build(BuildContext context) {
    // 🔒 BOARD GATE (חוק: מבחוץ לא רואים כלום) — worker-board screen.
    final session = ref.watch(boardAuthProvider);
    if (session == null || session.role != BoardRole.worker) {
      return const WelcomeScreen(boardRole: BoardRole.worker);
    }
    final username = session.username;
    final workerIndex = workerIndexForSession(session);

    final all = ref.watch(workerAttendanceProvider);
    final tasks = ref.watch(tasksProvider);
    final todayKey = attendanceDateKey(DateTime.now());
    AttendanceDay? today;
    for (final d in all) {
      if (d.username == username && d.date == todayKey) {
        today = d;
        break;
      }
    }
    final monthDays =
        attendanceMonth(all, username, _month.year, _month.month);
    final monthTotal = attendanceTotal(monthDays);
    final sentThisMonth = _sentMonths.contains(_monthKey);

    // Fast lookup: yyyy-MM-dd → that day's record (for the grid cells).
    final byKey = {for (final d in monthDays) d.date: d};

    return Scaffold(
      backgroundColor: BsTokens.bgLight,
      appBar: AppBar(
        backgroundColor: BsTokens.cardLight,
        elevation: 0,
        title: const Text(
          '🕐 נוכחות',
          style: TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black54),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          BsTokens.space4,
          BsTokens.space4,
          BsTokens.space4,
          BsTokens.space5,
        ),
        children: [
          _ClockCard(
            today: today,
            onClockIn: () => _clockIn(username),
            onClockOut: () => _clockOut(username),
          ),
          const SizedBox(height: BsTokens.space4),
          _CalendarCard(
            month: _month,
            byKey: byKey,
            total: monthTotal,
            dayCount: monthDays.length,
            canGoNext: !_viewingCurrentMonth,
            onPrev: () => setState(
              () => _month = DateTime(_month.year, _month.month - 1),
            ),
            onNext: () => setState(
              () => _month = DateTime(_month.year, _month.month + 1),
            ),
            onTapDay: (day) => _openDayDetail(day, workerIndex, tasks),
          ),
          const SizedBox(height: BsTokens.space4),
          _SendReportButton(
            enabled: monthDays.isNotEmpty && !sentThisMonth,
            label: sentThisMonth
                ? 'הדוח נשלח ✓'
                : (monthDays.isNotEmpty
                    ? '📨 שלח דוח נוכחות לקבלן'
                    : 'אין רישומים לשליחה בחודש זה'),
            onPressed: () => _sendReport(session, monthDays, monthTotal),
          ),
        ],
      ),
    );
  }

  /// Contract 4 — clock-in WITH a GPS fix. Reads [currentGeoFix] first (null on
  /// permission-denied / unsupported / error — no invented coordinate), then
  /// records attendance with whatever it got. A null fix is honest: the day is
  /// stamped without a location and the toast says so.
  Future<void> _clockIn(String username) async {
    final fix = await currentGeoFix();
    if (!mounted) return;
    final ok = ref
        .read(workerAttendanceProvider.notifier)
        .clockIn(username,
            lat: fix?.lat,
            lng: fix?.lng,
            employerId: ref.read(boardAuthProvider)?.employerId ?? '');
    if (!mounted) return;
    if (!ok) {
      showToast(context, 'כבר נרשמה כניסה להיום');
      return;
    }
    showToast(
      context,
      fix == null
          ? 'מיקום לא זמין — נרשמה כניסה ${_fmtTime(DateTime.now())} בלי מיקום'
          : '🟢 נרשמה כניסה ${_fmtTime(DateTime.now())} 📍',
    );
  }

  /// Contract 4 — clock-out WITH a GPS fix (same honest fallback).
  Future<void> _clockOut(String username) async {
    final fix = await currentGeoFix();
    if (!mounted) return;
    final notifier = ref.read(workerAttendanceProvider.notifier);
    final ok = notifier.clockOut(username, lat: fix?.lat, lng: fix?.lng);
    if (!mounted) return;
    if (!ok) {
      showToast(context, 'אין כניסה פתוחה להיום');
      return;
    }
    final worked = notifier.todayFor(username)?.worked;
    showToast(
      context,
      worked == null
          ? '🔴 נרשמה יציאה ${_fmtTime(DateTime.now())}'
          : '🔴 נרשמה יציאה · סה"כ היום ${_fmtDur(worked)} שעות',
    );
  }

  /// Tapping a populated calendar day → the day-detail bottom sheet
  /// (כניסה/יציאה+סה"כ · clickable location · honest per-day work summary).
  void _openDayDetail(
    AttendanceDay day,
    int workerIndex,
    List<TaskItem> tasks,
  ) {
    final summary = tasksForDay(tasks, workerIndex, day.date);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DayDetailSheet(day: day, work: summary),
    );
  }

  /// 'שלח דוח נוכחות לקבלן' — an honest in-app report: a summary chat line in
  /// the worker↔contractor thread (`th-worker-contractor`, sys_chat).
  void _sendReport(
    BoardSession session,
    List<AttendanceDay> monthDays,
    Duration total,
  ) {
    final text = '📋 דוח נוכחות ${_month.month}/${_month.year} — '
        '${session.displayName}: ${monthDays.length} ימי עבודה, '
        'סה"כ ${_fmtDur(total)} שעות';
    ref
        .read(chatEngineProvider.notifier)
        .send('th-worker-contractor', BsRole.worker, text);
    // Double-tap guard — this month is now sent (the button flips to a
    // disabled 'הדוח נשלח ✓').
    setState(() => _sentMonths.add(_monthKey));
    showToast(context, '📨 דוח הנוכחות נשלח לקבלן בצ׳אט');
  }
}

// ─── daily work summary (derived from tasksProvider) ───────────────────────────

/// One line of the per-day work summary — a task this worker advanced on the
/// calendar day, plus an HONEST note about WHICH timestamp dated it (the engine
/// has no dedicated completion-date field).
class DayWorkItem {
  const DayWorkItem({
    required this.name,
    required this.status,
    required this.completedThatDay,
    required this.stepsDone,
    required this.stepsTotal,
  });

  final String name;

  /// The task's CURRENT engine status (pending·active·review·done·rejected).
  final String status;

  /// True when the task's completedAt fell on this calendar day (a real
  /// completion stamp); false when the day was DERIVED from startedAt only
  /// (work began/was in-progress that day — labeled honestly in the sheet).
  final bool completedThatDay;

  final int stepsDone;
  final int stepsTotal;
}

/// Pure helper — [worker]'s tasks attributable to the calendar day [dateKey]
/// (`yyyy-MM-dd`), derived LIVE from [tasks]. HONEST derivation: the task
/// engine carries no completion-DATE field, only the task-clock instants
/// (`completedAt` / `startedAt`). A task is attributed to the day when its
/// `completedAt` lands on it (completed that day) or — failing that — its
/// `startedAt` does (work was in progress that day). Tasks with neither stamp
/// cannot be dated and are omitted (no invented attribution). Kept top-level so
/// the screen and tests share one derivation.
List<DayWorkItem> tasksForDay(
  List<TaskItem> tasks,
  int worker,
  String dateKey,
) {
  final out = <DayWorkItem>[];
  for (final t in tasks) {
    if (t.worker != worker) continue;
    final done = t.completedAt;
    final started = t.startedAt;
    final bool onDay;
    final bool completedThatDay;
    if (done != null && attendanceDateKey(done) == dateKey) {
      onDay = true;
      completedThatDay = true;
    } else if (started != null && attendanceDateKey(started) == dateKey) {
      onDay = true;
      completedThatDay = false;
    } else {
      onDay = false;
      completedThatDay = false;
    }
    if (!onDay) continue;
    out.add(DayWorkItem(
      name: t.name,
      status: t.status,
      completedThatDay: completedThatDay,
      stepsDone: t.doneSteps.length,
      stepsTotal: t.steps.length,
    ));
  }
  return out;
}

// ─── clock card ──────────────────────────────────────────────────────────────

/// Today's status + the big state-aware action: כניסה (no open shift) →
/// יציאה (clocked in) → an honestly-disabled "נרשמה נוכחות להיום ✓" once the
/// day is complete (one shift per day). Both actions capture GPS (contract 4).
class _ClockCard extends StatelessWidget {
  const _ClockCard({
    required this.today,
    required this.onClockIn,
    required this.onClockOut,
  });

  final AttendanceDay? today;
  final VoidCallback onClockIn;
  final VoidCallback onClockOut;

  @override
  Widget build(BuildContext context) {
    final inTs = today?.inTs;
    final outTs = today?.outTs;
    final worked = today?.worked;
    final hasLoc = mapsQueryForDay(today ?? _emptyDay) != null;

    final String label;
    final Color color;
    final VoidCallback? onTap;
    if (inTs == null) {
      label = '🟢 כניסה';
      color = BsTokens.success;
      onTap = onClockIn;
    } else if (outTs == null) {
      label = '🔴 יציאה';
      color = BsTokens.danger;
      onTap = onClockOut;
    } else {
      // Day complete — honestly disabled (no second shift per day).
      label = '✓ נרשמה נוכחות להיום';
      color = const Color(0xFFE9EAEC);
      onTap = null;
    }

    return Container(
      padding: const EdgeInsets.all(BsTokens.space4),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(cfgRadius(context)),
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
                  'היום',
                  style: TextStyle(
                    color: BsTokens.inkLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              // 📍 honest GPS chip — shows only once a location was actually
              // captured (no invented "location on" badge).
              if (hasLoc)
                const Text(
                  '📍 מיקום נרשם',
                  style: TextStyle(
                    color: BsTokens.successDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          const SizedBox(height: BsTokens.space3),
          // excludeSemantics — the inner Text equals the label; without it
          // TalkBack announces the button twice (F-50).
          Semantics(
            button: onTap != null,
            label: label,
            excludeSemantics: true,
            child: Material(
              color: color,
              borderRadius: BorderRadius.circular(cfgRadius(context)),
              child: InkWell(
                borderRadius: BorderRadius.circular(cfgRadius(context)),
                onTap: onTap,
                child: Container(
                  // Big primary target — comfortably above the 48dp floor.
                  constraints: const BoxConstraints(minHeight: 64),
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: TextStyle(
                      // bsOnAccent, not a hard Colors.white — high-contrast
                      // mode darkens the foreground on accent fills (F-28).
                      color: onTap == null
                          ? BsTokens.mutedLight
                          : bsOnAccent(context),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: BsTokens.space3),
          Row(
            children: [
              _TodayStat(
                label: 'כניסה',
                value: inTs == null ? '—' : _fmtTime(inTs),
              ),
              _TodayStat(
                label: 'יציאה',
                value: outTs == null ? '—' : _fmtTime(outTs),
              ),
              _TodayStat(
                label: 'סה"כ שעות',
                value: worked == null ? '—' : _fmtDur(worked),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A throwaway zero-record used only to ask [mapsQueryForDay] about a missing
/// `today` without a null-branch (the helper returns null on no coordinates).
const AttendanceDay _emptyDay = AttendanceDay(username: '', date: '');

class _TodayStat extends StatelessWidget {
  const _TodayStat({required this.label, required this.value});

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

// ─── calendar card ─────────────────────────────────────────────────────────────

/// Hebrew month names (calendar labels, not business data).
const List<String> _kHebMonths = [
  'ינואר', 'פברואר', 'מרץ', 'אפריל', 'מאי', 'יוני',
  'יולי', 'אוגוסט', 'ספטמבר', 'אוקטובר', 'נובמבר', 'דצמבר',
];

/// Weekday column headers, Sunday→Saturday (Israeli work week, RTL order is
/// handled by the row's natural RTL direction).
const List<String> _kHebWeekdays = ['א', 'ב', 'ג', 'ד', 'ה', 'ו', 'ש'];

/// The month picker + the full 7-column calendar GRID + the monthly total.
class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.month,
    required this.byKey,
    required this.total,
    required this.dayCount,
    required this.canGoNext,
    required this.onPrev,
    required this.onNext,
    required this.onTapDay,
  });

  final DateTime month;

  /// `yyyy-MM-dd` → that day's record (only populated days are present).
  final Map<String, AttendanceDay> byKey;
  final Duration total;
  final int dayCount;

  /// False on the current month — the future is honestly unreachable.
  final bool canGoNext;

  final VoidCallback onPrev;
  final VoidCallback onNext;
  final void Function(AttendanceDay day) onTapDay;

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // weekday: Dart Mon=1..Sun=7; calendar starts Sunday → leading blanks.
    final leadBlanks = firstOfMonth.weekday % 7; // Sun→0, Mon→1 … Sat→6
    final todayKey = attendanceDateKey(DateTime.now());

    // Build the cell list: leading blanks, then each day-of-month.
    final cells = <Widget>[];
    for (var i = 0; i < leadBlanks; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (var dom = 1; dom <= daysInMonth; dom++) {
      final date = DateTime(month.year, month.month, dom);
      final key = attendanceDateKey(date);
      final rec = byKey[key];
      cells.add(_DayCell(
        dom: dom,
        record: rec,
        isToday: key == todayKey,
        onTap: rec == null ? null : () => onTapDay(rec),
      ));
    }

    return Container(
      padding: const EdgeInsets.all(BsTokens.space4),
      decoration: BoxDecoration(
        color: BsTokens.cardLight,
        borderRadius: BorderRadius.circular(cfgRadius(context)),
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
          // Month picker — labeled text buttons (≥48dp), no bare chevron
          // icons so RTL direction stays unambiguous (gate #62). The future
          // month is honestly unreachable (disabled 'הבא').
          Row(
            children: [
              TextButton(
                onPressed: onPrev,
                style: TextButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  foregroundColor: BsTokens.mutedLight,
                ),
                child: const Text('‹ הקודם', style: TextStyle(fontSize: 13)),
              ),
              Expanded(
                child: Text(
                  '${_kHebMonths[month.month - 1]} ${month.year}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              TextButton(
                onPressed: canGoNext ? onNext : null,
                style: TextButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  foregroundColor: BsTokens.mutedLight,
                ),
                child: const Text('הבא ›', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: BsTokens.space2),
          // Weekday header row (Sun→Sat).
          Row(
            children: [
              for (final w in _kHebWeekdays)
                Expanded(
                  child: Text(
                    w,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: BsTokens.mutedLight,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: BsTokens.space1),
          // The grid — 7 columns, square-ish cells, RTL-laid-out.
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 0.82,
            children: cells,
          ),
          if (dayCount == 0) ...[
            const SizedBox(height: BsTokens.space2),
            const Text(
              'אין רישומי נוכחות בחודש זה',
              textAlign: TextAlign.center,
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
            ),
          ] else ...[
            const Divider(height: 20, color: Color(0xFFF2F3F5)),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'סה"כ חודשי',
                    style: TextStyle(
                      color: BsTokens.inkLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  '$dayCount ימים · ${_fmtDur(total)} שעות',
                  style: const TextStyle(
                    color: BsTokens.brandDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// One calendar cell. A populated day shows its number, a tiny total-hours
/// chip, and a 📍 dot when a location was recorded; tapping opens the detail
/// sheet. An empty day is a muted number with no tap (honest — nothing there).
class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.dom,
    required this.record,
    required this.isToday,
    required this.onTap,
  });

  final int dom;
  final AttendanceDay? record;
  final bool isToday;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final rec = record;
    final worked = rec?.worked;
    final hasLoc = rec != null && mapsQueryForDay(rec) != null;
    final filled = rec != null;

    final bg = filled
        ? const Color(0xFFFFF4EA) // brand-tinted = has a record
        : Colors.transparent;
    final border = isToday
        ? Border.all(color: BsTokens.brand, width: 1.6)
        : Border.all(color: const Color(0xFFEDEEF0));

    return Semantics(
      button: onTap != null,
      label: filled
          ? 'יום $dom, ${worked == null ? 'משמרת פתוחה' : '${_fmtDur(worked)} שעות'}'
          : 'יום $dom, אין רישום',
      excludeSemantics: true,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: border,
            ),
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$dom',
                  style: TextStyle(
                    color: filled ? BsTokens.inkLight : BsTokens.mutedLight,
                    fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                if (filled) ...[
                  const SizedBox(height: 2),
                  Text(
                    worked == null ? '•••' : _fmtDur(worked),
                    style: const TextStyle(
                      color: BsTokens.brandDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 9.5,
                    ),
                  ),
                  if (hasLoc)
                    const Text(
                      '📍',
                      style: TextStyle(fontSize: 8),
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

// ─── day-detail sheet ──────────────────────────────────────────────────────────

/// The day drill-down: כניסה/יציאה+סה"כ, the CLICKABLE location (contract 3 —
/// [openNavSheet] to Waze / Google Maps; honestly hidden when no coordinate was
/// recorded), and the HONEST per-day work summary from [tasksProvider].
class _DayDetailSheet extends StatelessWidget {
  const _DayDetailSheet({required this.day, required this.work});

  final AttendanceDay day;
  final List<DayWorkItem> work;

  @override
  Widget build(BuildContext context) {
    final inTs = day.inTs;
    final outTs = day.outTs;
    final worked = day.worked;
    final loc = mapsQueryForDay(day);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.all(BsTokens.space2),
          padding: const EdgeInsets.all(BsTokens.space4),
          decoration: BoxDecoration(
            color: BsTokens.cardLight,
            borderRadius: BorderRadius.circular(cfgRadius(context)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '🗓️ ${_fmtDateKeyLong(day.date)}',
                      style: const TextStyle(
                        color: BsTokens.inkLight,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  // ✕ explicit close (≥48dp).
                  Semantics(
                    button: true,
                    label: 'סגור',
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.of(context).maybePop(),
                      child: const SizedBox(
                        width: 48,
                        height: 48,
                        child: Icon(Icons.close, color: BsTokens.mutedLight),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: BsTokens.space2),
              // Clock row.
              Row(
                children: [
                  _TodayStat(
                    label: 'כניסה',
                    value: inTs == null ? '—' : _fmtTime(inTs),
                  ),
                  _TodayStat(
                    label: 'יציאה',
                    value: outTs == null ? '—' : _fmtTime(outTs),
                  ),
                  _TodayStat(
                    label: 'סה"כ שעות',
                    value: worked == null ? '—' : _fmtDur(worked),
                  ),
                ],
              ),
              const SizedBox(height: BsTokens.space3),
              // 📍 CLICKABLE location — contract 3. Honest: only when a
              // coordinate was actually recorded for the day.
              if (loc != null)
                _LocationButton(
                  label: '${_fmtDateKeyLong(day.date)} — מיקום כניסה',
                  query: loc,
                )
              else
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: BsTokens.space2),
                  child: Text(
                    '📍 לא נרשם מיקום ביום זה',
                    style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
                  ),
                ),
              const Divider(height: 24, color: Color(0xFFF2F3F5)),
              const Text(
                'סיכום עבודה יומי',
                style: TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: BsTokens.space2),
              if (work.isEmpty)
                // Honest empty state — the engine has no task dated to this day.
                const Text(
                  'אין פירוט-עבודה משויך ליום זה',
                  style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
                )
              else
                for (final w in work) _WorkLine(item: w),
            ],
          ),
        ),
      ),
    );
  }
}

/// The clickable location pill — opens the internal nav sheet (contract 3).
class _LocationButton extends StatelessWidget {
  const _LocationButton({required this.label, required this.query});

  final String label;

  /// `"lat,lng"` from [mapsQueryForDay] — passed through to [openNavSheet].
  final String query;

  @override
  Widget build(BuildContext context) {
    final parts = query.split(',');
    final lat = parts.length == 2 ? double.tryParse(parts[0]) : null;
    final lng = parts.length == 2 ? double.tryParse(parts[1]) : null;
    return Semantics(
      button: true,
      label: 'פתח ניווט למיקום',
      excludeSemantics: true,
      child: Material(
        color: const Color(0xFFEAF3FF),
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          onTap: () => openNavSheet(context, label: label, lat: lat, lng: lng),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: BsTokens.space3),
            child: Row(
              children: [
                const Icon(Icons.place, color: Color(0xFF1D6FE0), size: 20),
                const SizedBox(width: BsTokens.space2),
                Expanded(
                  child: Text(
                    'מיקום הכניסה — פתח ניווט',
                    style: const TextStyle(
                      color: Color(0xFF1D4ED8),
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                ),
                const Icon(Icons.navigation_outlined,
                    color: Color(0xFF1D6FE0), size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One per-day work-summary line — task name + a status chip + (when known) the
/// step progress, with an HONEST note when the day was derived from the
/// start-time rather than a real completion stamp.
class _WorkLine extends StatelessWidget {
  const _WorkLine({required this.item});

  final DayWorkItem item;

  @override
  Widget build(BuildContext context) {
    final statusLabel = kTaskStatusLabel[item.status] ?? item.status;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.completedThatDay ? '✓ ' : '• ',
            style: TextStyle(
              color: item.completedThatDay
                  ? BsTokens.successDark
                  : BsTokens.mutedLight,
              fontWeight: FontWeight.w800,
              fontSize: 13.5,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
                Text(
                  // Honest provenance: a real completion stamp vs a derived
                  // "in progress that day" attribution.
                  [
                    statusLabel,
                    if (item.stepsTotal > 0)
                      '${item.stepsDone}/${item.stepsTotal} שלבים',
                    if (!item.completedThatDay) 'התחיל ביום זה',
                  ].join(' · '),
                  style: const TextStyle(
                    color: BsTokens.mutedLight,
                    fontSize: 12,
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

// ─── send-report button ──────────────────────────────────────────────────────

/// 'שלח דוח נוכחות לקבלן' — brand pill; honestly disabled (muted) when the
/// viewed month has no records, or after the report was already sent
/// ('הדוח נשלח ✓' — the double-tap guard).
class _SendReportButton extends StatelessWidget {
  const _SendReportButton({
    required this.enabled,
    required this.label,
    required this.onPressed,
  });

  final bool enabled;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // excludeSemantics — the inner Text equals the label (F-50).
    return Semantics(
      button: enabled,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: enabled ? BsTokens.brand : const Color(0xFFE9EAEC),
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          onTap: enabled ? onPressed : null,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                // bsOnAccent on the brand fill (F-28).
                color: enabled ? bsOnAccent(context) : BsTokens.mutedLight,
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── formatting helpers ──────────────────────────────────────────────────────

String _fmtTime(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// `H:mm` shift length (e.g. 7:45).
String _fmtDur(Duration d) =>
    '${d.inHours}:${(d.inMinutes % 60).toString().padLeft(2, '0')}';

/// `yyyy-MM-dd` → `d בMMMM yyyy` (the sheet's long date), Hebrew month name.
String _fmtDateKeyLong(String key) {
  final parts = key.split('-');
  if (parts.length != 3) return key;
  final y = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  final d = int.tryParse(parts[2]);
  if (y == null || m == null || d == null || m < 1 || m > 12) return key;
  return '$d ב${_kHebMonths[m - 1]} $y';
}
