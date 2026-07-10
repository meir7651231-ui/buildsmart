// Wave S-c — the CONTRACTOR's live attendance ROSTER: a read-only bottom-sheet
// listing THIS employer's WORKER attendance (the S-a `attendanceForEmployer`
// Provider.family, keyed by employerId; couriers are excluded by construction).
// PARALLEL to the contractor HR sheet (contractor_hr_sheet.dart) — same
// showXSheet + DraggableScrollableSheet/ListView + RTL + header/close idiom —
// but this surface is purely OBSERVATIONAL: the contractor watches who's
// on-site now and who has a record today; they do NOT edit attendance (the
// worker owns their own clock-in/out, worker_attendance_screen.dart).
//
// Two sections:
//   🟢 נוכחים עכשיו — the OPEN days (`clockedInNow`): clocked in, not out, today.
//   היום           — every worker WITH a record today (open or closed shifts).
//
// HONEST by construction: only data that exists is shown. A still-open shift's
// יציאה renders '—'; hours appear only once the shift is closed (`worked`); a
// 📍 pill appears only when a GPS fix was actually captured at clock-in
// (`mapsQueryForDay` → null → no pill, never an invented coordinate). The pill
// REUSES the #111 internal nav sheet (`openNavSheet`, services/nav_launch.dart)
// — the same Waze / Google Maps deep-link the worker's day-detail uses.
//
// SERVER-SWAP: kDemoContractorId is the single-device demo employer id; the
// real contractor uid when the backend lands (as the other contractor sheets).

import 'package:buildsmart/services/nav_launch.dart';
import 'package:buildsmart/state/board_auth.dart' show kDemoContractorId;
import 'package:buildsmart/state/worker_attendance.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Open the contractor's worker-attendance roster — the wire target for the
/// '🕒 נוכחות עובדים' action on `tasks_screen`.
Future<void> showContractorAttendanceSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _ContractorAttendanceSheet(),
  );
}

class _ContractorAttendanceSheet extends ConsumerWidget {
  const _ContractorAttendanceSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The LIVE roster — every WORKER attendance row scoped to THIS employer
    // (S-a Provider.family; couriers excluded by construction). SERVER-SWAP:
    // kDemoContractorId is the demo employer id; the real uid when the backend
    // lands (mirrors the other contractor sheets).
    final all = ref.watch(attendanceForEmployer(kDemoContractorId));
    final todayKey = attendanceDateKey(DateTime.now());
    // Who's on-site NOW — the open days (clocked in, not out, today).
    final present = clockedInNow(all, todayKey);
    // Everyone WITH a record today (open or closed) — the day's roster.
    final todayAll = [for (final d in all) if (d.date == todayKey) d];

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
              // Header row — title + a ✕ close (≥48dp tap target).
              Row(
                children: [
                  const Expanded(
                    child: CfgText(
                      'contractor_attendance_sheet.header',
                      '🕒 נוכחות עובדים',
                      style: TextStyle(
                        color: BsTokens.inkLight,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    key: const ValueKey('contractor-attendance-close'),
                    iconSize: 24,
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    tooltip: 'סגור',
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.close, color: BsTokens.mutedLight),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              const CfgText(
                'contractor_attendance_sheet.subtitle',
                'מי מהעובדים שלך מחותם כרגע ומי נכח היום (לצפייה בלבד)',
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
              ),
              const SizedBox(height: BsTokens.space3),

              // ══ SECTION — 🟢 נוכחים עכשיו ══
              Text(
                '🟢 נוכחים עכשיו (${present.length})',
                style: const TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: BsTokens.space3),
              if (present.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: BsTokens.space5),
                  child: CfgText(
                    'contractor_attendance_sheet.empty_present',
                    'אין עובדים מחותמים כרגע',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: BsTokens.inkLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                )
              else
                for (final d in present) ...[
                  _PresentRow(day: d),
                  const SizedBox(height: BsTokens.space2),
                ],

              // ══ SECTION — היום ══
              const Divider(height: 32),
              const CfgText(
                'contractor_attendance_sheet.today',
                'היום',
                style: TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: BsTokens.space3),
              if (todayAll.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: BsTokens.space5),
                  child: CfgText(
                    'contractor_attendance_sheet.empty_today',
                    'אין נוכחות רשומה היום',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: BsTokens.inkLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                )
              else
                for (final d in todayAll) ...[
                  _TodayRow(day: d),
                  const SizedBox(height: BsTokens.space2),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

/// One "נוכח עכשיו" row — `🟢 username` + clock-in time and (when a GPS fix was
/// captured) a 📍 location pill that opens the internal nav sheet (#111). The
/// pill is omitted entirely when no coordinate exists (honest — no fake point).
class _PresentRow extends StatelessWidget {
  const _PresentRow({required this.day});

  final AttendanceDay day;

  @override
  Widget build(BuildContext context) {
    final inTs = day.inTs;
    return Container(
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: BsTokens.bgLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '🟢 ${day.username}',
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                inTs == null ? 'כניסה —' : 'כניסה ${_fmtTime(inTs)}',
                style: const TextStyle(
                  color: BsTokens.successDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          // 📍 location pill — only when a coordinate was actually captured at
          // clock-in (mapsQueryForDay → null → no pill, never invented).
          if (mapsQueryForDay(day) != null) ...[
            const SizedBox(height: BsTokens.space2),
            _LocationPill(day: day),
          ],
        ],
      ),
    );
  }
}

/// One "היום" row — `🦺 username` + the day's in→out times (out '—' while the
/// shift is still open) and, once the shift is closed, the hours worked. These
/// are worker rows (the employer query is worker-only), so the 🦺 icon is
/// always correct. READ-ONLY — no actions.
class _TodayRow extends StatelessWidget {
  const _TodayRow({required this.day});

  final AttendanceDay day;

  @override
  Widget build(BuildContext context) {
    final inTs = day.inTs;
    final outTs = day.outTs;
    final worked = day.worked;
    return Container(
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: BsTokens.bgLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '🦺 ${day.username}',
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              // Closed shift → hours pill; open shift → no hours yet (honest).
              if (worked != null)
                Text(
                  '${_fmtDur(worked)} שעות',
                  style: const TextStyle(
                    color: BsTokens.brandDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'כניסה ${inTs == null ? '—' : _fmtTime(inTs)} · '
            'יציאה ${outTs == null ? '—' : _fmtTime(outTs)}',
            style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

/// The clickable 📍 location pill — opens the internal nav sheet (#111,
/// [openNavSheet] → Waze / Google Maps), navigating to the worker's clock-in
/// coordinate. Only rendered by [_PresentRow] when [AttendanceDay.inLat]/inLng
/// are non-null, so the coordinate is always real.
class _LocationPill extends StatelessWidget {
  const _LocationPill({required this.day});

  final AttendanceDay day;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEAF3FF),
      borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      child: InkWell(
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        // inLat/inLng are non-null here (the caller gates on mapsQueryForDay);
        // openNavSheet navigates to the exact clock-in point.
        onTap: () => openNavSheet(
          context,
          label: '${day.username} — מיקום כניסה',
          lat: day.inLat,
          lng: day.inLng,
        ),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: BsTokens.space3),
          child: const Row(
            children: [
              Icon(Icons.place, color: Color(0xFF1D6FE0), size: 20),
              SizedBox(width: BsTokens.space2),
              Expanded(
                child: CfgText(
                  'contractor_attendance_sheet.location',
                  'מיקום הכניסה — פתח ניווט',
                  style: TextStyle(
                    color: Color(0xFF1D4ED8),
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
              ),
              Icon(Icons.navigation_outlined,
                  color: Color(0xFF1D6FE0), size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

/// `HH:mm` wall-clock label — a small local formatter matching
/// worker_attendance_screen's `_fmtTime` (the screen's helper is file-private;
/// no dart:intl in this codebase, so we format by hand).
String _fmtTime(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:'
    '${t.minute.toString().padLeft(2, '0')}';

/// `H:mm` completed-shift length (e.g. 7:45) — matches worker_attendance_screen's
/// `_fmtDur`. Only called with a closed shift's non-null `worked` duration.
String _fmtDur(Duration d) =>
    '${d.inHours}:${(d.inMinutes % 60).toString().padLeft(2, '0')}';
