import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/worker_attendance.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🕐 נוכחות (cluster #85ח) — the worker's clock-in/out screen: a big
/// state-aware כניסה/יציאה button, today's status, a monthly table
/// (תאריך·כניסה·יציאה·סה"כ שעות) with a month picker + monthly total, and
/// 'שלח דוח נוכחות לקבלן' which posts an honest summary line into the
/// worker↔contractor chat thread (the board's existing report channel —
/// same in-app pattern the reports use; no fake export).
///
/// Data: [workerAttendanceProvider] (bs.worker-attendance.v1) — on-device,
/// per logged username. SERVER-SWAP: server attendance ledger later.
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
  /// First day of the month the table shows — starts on the current month.
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

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

    final all = ref.watch(workerAttendanceProvider);
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
          _MonthCard(
            month: _month,
            days: monthDays,
            total: monthTotal,
            canGoNext: !_viewingCurrentMonth,
            onPrev: () => setState(
              () => _month = DateTime(_month.year, _month.month - 1),
            ),
            onNext: () => setState(
              () => _month = DateTime(_month.year, _month.month + 1),
            ),
          ),
          const SizedBox(height: BsTokens.space4),
          _SendReportButton(
            enabled: monthDays.isNotEmpty,
            onPressed: () => _sendReport(session, monthDays, monthTotal),
          ),
        ],
      ),
    );
  }

  void _clockIn(String username) {
    final ok =
        ref.read(workerAttendanceProvider.notifier).clockIn(username);
    showToast(
      context,
      ok
          ? '🟢 נרשמה כניסה ${_fmtTime(DateTime.now())}'
          : 'כבר נרשמה כניסה להיום',
    );
  }

  void _clockOut(String username) {
    final notifier = ref.read(workerAttendanceProvider.notifier);
    final ok = notifier.clockOut(username);
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

  /// 'שלח דוח נוכחות לקבלן' — an honest in-app report: a summary chat line in
  /// the worker↔contractor thread (`th-worker-contractor`, sys_chat). The
  /// contractor's שיחות tab admits worker-audience threads he participates in
  /// (`_visibleToAudience`, chats_screen.dart), so the report lands live there
  /// (thread 'עובד — רן').
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
    showToast(context, '📨 דוח הנוכחות נשלח לקבלן בצ׳אט');
  }
}

// ─── clock card ──────────────────────────────────────────────────────────────

/// Today's status + the big state-aware action: כניסה (no open shift) →
/// יציאה (clocked in) → an honestly-disabled "נרשמה נוכחות להיום ✓" once the
/// day is complete (one shift per day).
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
          const Text(
            'היום',
            style: TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: BsTokens.space3),
          Semantics(
            button: onTap != null,
            label: label,
            child: Material(
              color: color,
              borderRadius: BorderRadius.circular(BsTokens.radiusCard),
              child: InkWell(
                borderRadius: BorderRadius.circular(BsTokens.radiusCard),
                onTap: onTap,
                child: Container(
                  // Big primary target — comfortably above the 48dp floor.
                  constraints: const BoxConstraints(minHeight: 64),
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: TextStyle(
                      color:
                          onTap == null ? BsTokens.mutedLight : Colors.white,
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

// ─── month card ──────────────────────────────────────────────────────────────

/// Hebrew month names (calendar labels, not business data).
const List<String> _kHebMonths = [
  'ינואר', 'פברואר', 'מרץ', 'אפריל', 'מאי', 'יוני',
  'יולי', 'אוגוסט', 'ספטמבר', 'אוקטובר', 'נובמבר', 'דצמבר',
];

/// The month picker + the תאריך·כניסה·יציאה·סה"כ table + the monthly total.
class _MonthCard extends StatelessWidget {
  const _MonthCard({
    required this.month,
    required this.days,
    required this.total,
    required this.canGoNext,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime month;
  final List<AttendanceDay> days;
  final Duration total;

  /// False on the current month — the future is honestly unreachable.
  final bool canGoNext;

  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
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
          // Month picker — labeled text buttons (≥48dp), no bare chevron
          // icons so RTL direction stays unambiguous (gate #62).
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
          if (days.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: BsTokens.space3),
              child: Text(
                'אין רישומי נוכחות בחודש זה',
                textAlign: TextAlign.center,
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
              ),
            )
          else ...[
            const _TableRow(
              date: 'תאריך',
              inText: 'כניסה',
              outText: 'יציאה',
              totalText: 'סה"כ שעות',
              header: true,
            ),
            const Divider(height: 12, color: Color(0xFFF2F3F5)),
            for (final d in days.reversed) // newest first
              _TableRow(
                date: _fmtDateKey(d.date),
                inText: d.inTs == null ? '—' : _fmtTime(d.inTs!),
                outText: d.outTs == null ? '—' : _fmtTime(d.outTs!),
                totalText: d.worked == null ? '—' : _fmtDur(d.worked!),
              ),
            const Divider(height: 16, color: Color(0xFFF2F3F5)),
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
                  '${days.length} ימים · ${_fmtDur(total)} שעות',
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

/// One table line — 4 columns (header renders bold-muted).
class _TableRow extends StatelessWidget {
  const _TableRow({
    required this.date,
    required this.inText,
    required this.outText,
    required this.totalText,
    this.header = false,
  });

  final String date;
  final String inText;
  final String outText;
  final String totalText;
  final bool header;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: header ? BsTokens.mutedLight : BsTokens.inkLight,
      fontSize: header ? 12 : 13.5,
      fontWeight: header ? FontWeight.w700 : FontWeight.w600,
    );
    Widget cell(String t, int flex) =>
        Expanded(flex: flex, child: Text(t, style: style));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          cell(date, 3),
          cell(inText, 2),
          cell(outText, 2),
          cell(totalText, 3),
        ],
      ),
    );
  }
}

// ─── send-report button ──────────────────────────────────────────────────────

/// 'שלח דוח נוכחות לקבלן' — brand pill; honestly disabled (muted) when the
/// viewed month has no records to report.
class _SendReportButton extends StatelessWidget {
  const _SendReportButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: enabled,
      label: 'שלח דוח נוכחות לקבלן',
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
              enabled
                  ? '📨 שלח דוח נוכחות לקבלן'
                  : 'אין רישומים לשליחה בחודש זה',
              style: TextStyle(
                color: enabled ? Colors.white : BsTokens.mutedLight,
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

/// `yyyy-MM-dd` → `d.M` (the table's compact date).
String _fmtDateKey(String key) {
  final parts = key.split('-');
  if (parts.length != 3) return key;
  final m = int.tryParse(parts[1]);
  final d = int.tryParse(parts[2]);
  if (m == null || d == null) return key;
  return '$d.$m';
}
