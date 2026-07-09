import 'package:buildsmart/screens/courier_reports_tab.dart'
    show CourierReportsTab;
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/state/board_auth.dart';
// courier_hr.dart re-exports the shared attendance model + helpers
// (AttendanceDay, attendanceDateKey, attendanceMonth, attendanceTotal) —
// NO model duplication (#86.2).
import 'package:buildsmart/state/courier_hr.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/worker_notifs.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🕐 נוכחות שליח (#86.2 · F-15) — the courier's clock-in/out screen: a big
/// state-aware כניסה/יציאה button, today's status, a monthly table
/// (תאריך·כניסה·יציאה·סה"כ שעות) with a month picker + monthly total, and
/// 'שלח דוח נוכחות לחנות' which posts an honest summary line into the
/// store↔courier chat thread ([kCourierAttendanceReportThreadId]) — the
/// courier reports to the STORE, not to a contractor.
///
/// Data: [courierAttendanceProvider] (bs.courier-attendance.v1) — on-device,
/// per logged username, fully isolated from the worker ledger (F-7).
class CourierAttendanceScreen extends ConsumerStatefulWidget {
  const CourierAttendanceScreen({super.key});

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const CourierAttendanceScreen());

  @override
  ConsumerState<CourierAttendanceScreen> createState() =>
      _CourierAttendanceScreenState();
}

class _CourierAttendanceScreenState
    extends ConsumerState<CourierAttendanceScreen> {
  /// First day of the month the table shows — starts on the current month.
  late DateTime _month;

  /// Months ('yyyy-MM') whose report was already sent this session — the
  /// double-tap guard (F-15): a second tap cannot post a duplicate report.
  final Set<String> _sentMonths = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  String get _monthKey =>
      '${_month.year.toString().padLeft(4, '0')}-'
      '${_month.month.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    // 🔒 BOARD GATE (חוק: מבחוץ לא רואים כלום) — COURIER-board screen (F-16):
    // the gate is courier-roled, never a blind copy of the worker gate.
    final session = ref.watch(boardAuthProvider);
    if (session == null || session.role != BoardRole.courier) {
      return const WelcomeScreen(boardRole: BoardRole.courier);
    }
    final username = session.username;

    final all = ref.watch(courierAttendanceProvider);
    final todayKey = attendanceDateKey(DateTime.now());
    AttendanceDay? today;
    for (final d in all) {
      if (d.username == username && d.date == todayKey) {
        today = d;
        break;
      }
    }
    final monthDays = attendanceMonth(all, username, _month.year, _month.month);
    final monthTotal = attendanceTotal(monthDays);
    final sentThisMonth = _sentMonths.contains(_monthKey);

    // Clock-skew safe (F-15): computed per build against the REAL current
    // month, so a viewed month can never navigate past it — even if _month
    // somehow got ahead, canGoNext stays false until it is truly behind now.
    final now = DateTime.now();
    final canGoNext = DateTime(
      _month.year,
      _month.month,
    ).isBefore(DateTime(now.year, now.month));

    return Scaffold(
      backgroundColor: BsTokens.bgLight,
      appBar: AppBar(
        backgroundColor: BsTokens.cardLight,
        elevation: 0,
        title: const CfgText(
          'courier.attend.title',
          '🕐 נוכחות',
          style: TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black54),
        actions: const [HelpToggleButton()],
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
            canGoNext: canGoNext,
            onPrev:
                () => setState(
                  () => _month = DateTime(_month.year, _month.month - 1),
                ),
            onNext:
                () => setState(
                  () => _month = DateTime(_month.year, _month.month + 1),
                ),
          ),
          const SizedBox(height: BsTokens.space4),
          _SendReportButton(
            enabled: monthDays.isNotEmpty && !sentThisMonth,
            label:
                sentThisMonth
                    ? 'הדוח נשלח ✓'
                    : (monthDays.isNotEmpty
                        ? '📨 שלח דוח נוכחות לחנות'
                        : 'אין רישומים לשליחה בחודש זה'),
            onPressed: () => _sendReport(session, monthDays, monthTotal),
          ),
        ],
      ),
    );
  }

  void _clockIn(String username) {
    // clockIn/clockOut are state-guarded (idempotent) in the notifier — a
    // double-tap is an honest no-op toast, never a second shift.
    final ok = ref.read(courierAttendanceProvider.notifier).clockIn(username);
    showToast(
      context,
      ok
          ? '🟢 נרשמה כניסה ${_fmtTime(DateTime.now())}'
          : 'כבר נרשמה כניסה להיום',
    );
  }

  void _clockOut(String username) {
    final notifier = ref.read(courierAttendanceProvider.notifier);
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

  /// 'שלח דוח נוכחות לחנות' (#86.2) — an honest in-app report: a summary chat
  /// line in the store↔courier thread [kCourierAttendanceReportThreadId]
  /// ('th-store-courier-pickups', audience 'store') sent as [BsRole.courier],
  /// so the report lands in the SUPPLIER's chat tab — the intended recipient
  /// (לחנות, לא לקבלן). The courier's own שיחות tab surfaces the thread via
  /// the store↔courier audience pairing in chats_screen (F-25).
  void _sendReport(
    BoardSession session,
    List<AttendanceDay> monthDays,
    Duration total,
  ) {
    // Guard: send() is a silent no-op on an unknown thread — never toast a
    // success that did not happen (the courier_reports_tab idiom).
    final exists = ref
        .read(chatEngineProvider)
        .any((t) => t.id == kCourierAttendanceReportThreadId);
    if (!exists) {
      showToast(context, 'שיחת החנות לא נמצאה — הדוח לא נשלח');
      return;
    }
    // The line carries the sender's display name — fromRole=courier alone is
    // not an identity when more than one courier exists.
    final text =
        '📋 דוח נוכחות ${_month.month}/${_month.year} — '
        '${session.displayName}: ${monthDays.length} ימי עבודה, '
        'סה"כ ${_fmtDur(total)} שעות';
    ref
        .read(chatEngineProvider.notifier)
        .send(kCourierAttendanceReportThreadId, BsRole.courier, text);
    // Bell notification for the store board (#82 supplier bell), addressed to
    // the single seeded store account ([CourierReportsTab.kStoreUsername]).
    // SERVER-SWAP: הפעמון ממוען לחשבון החנות היחיד ב-seed; סשן demo של החנות
    // לא מקבל פעמון — יוחלף במיעון אמיתי (uid) עם חיבור השרת.
    ref
        .read(workerNotifsProvider.notifier)
        .addNotification(
          username: CourierReportsTab.kStoreUsername,
          emoji: '📋',
          title: 'דוח נוכחות מהשליח 🛵',
          body:
              '${session.displayName}: ${monthDays.length} ימי עבודה · '
              '${_fmtDur(total)} שעות (${_month.month}/${_month.year})',
        );
    // Double-tap guard — this month is now sent (the button flips to a
    // disabled 'הדוח נשלח ✓').
    setState(() => _sentMonths.add(_monthKey));
    showToast(context, '📨 דוח הנוכחות נשלח לחנות בצ׳אט');
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
          const CfgText(
            'courier.attend.today',
            'היום',
            style: TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: BsTokens.space3),
          // excludeSemantics — the inner Text equals the label; without it
          // TalkBack announces the button twice (F-50).
          HelpTarget(
            title: 'כניסה / יציאה',
            body:
                'רישום נוכחות: לחיצה ראשונה רושמת כניסה (ירוק), השנייה '
                'יציאה (אדום). לאחר השלמת היום הכפתור ננעל — משמרת אחת ליום.',
            child: Semantics(
              button: onTap != null,
              label: label,
              excludeSemantics: true,
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
                        // bsOnAccent, not a hard Colors.white — high-contrast
                        // mode darkens the foreground on accent fills (F-28).
                        color:
                            onTap == null
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
  'ינואר',
  'פברואר',
  'מרץ',
  'אפריל',
  'מאי',
  'יוני',
  'יולי',
  'אוגוסט',
  'ספטמבר',
  'אוקטובר',
  'נובמבר',
  'דצמבר',
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

  /// False on (or past) the real current month — the future is honestly
  /// unreachable (clock-skew safe; computed per build by the screen).
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
              HelpTarget(
                title: 'חודש קודם',
                body: 'מציג את טבלת הנוכחות של החודש הקודם.',
                child: TextButton(
                  onPressed: onPrev,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    foregroundColor: BsTokens.mutedLight,
                  ),
                  child: const CfgText(
                    'courier.attend.prev',
                    '‹ הקודם',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
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
              HelpTarget(
                title: 'חודש הבא',
                body:
                    'מציג את טבלת הנוכחות של החודש הבא — מושבת על החודש '
                    'הנוכחי (אין עתיד).',
                child: TextButton(
                  onPressed: canGoNext ? onNext : null,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    foregroundColor: BsTokens.mutedLight,
                  ),
                  child: const CfgText(
                    'courier.attend.next',
                    'הבא ›',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: BsTokens.space2),
          if (days.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: BsTokens.space3),
              child: CfgText(
                'courier.attend.empty',
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
                  child: CfgText(
                    'courier.attend.month_total',
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

/// 'שלח דוח נוכחות לחנות' — brand pill; honestly disabled (muted) when the
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
    return HelpTarget(
      title: 'שלח דוח נוכחות לחנות',
      body:
          'שולח לחנות סיכום נוכחות חודשי (ימי עבודה + סה"כ שעות) כהודעת '
          'צ׳אט + פעמון. ננעל אחרי שליחה למניעת כפילות.',
      child: Semantics(
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
