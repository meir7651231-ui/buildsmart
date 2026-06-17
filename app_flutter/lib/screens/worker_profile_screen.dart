import 'package:buildsmart/data/board_accounts_local.dart';
import 'package:buildsmart/logic/input_validators.dart';
import 'package:buildsmart/screens/role_picker_sheet.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/screens/worker_attendance_screen.dart';
import 'package:buildsmart/screens/worker_forms_screen.dart';
import 'package:buildsmart/screens/worker_payslips_sheet.dart';
import 'package:buildsmart/screens/worker_safety_screen.dart';
import 'package:buildsmart/screens/worker_settings_screen.dart';
import 'package:buildsmart/services/task_photo.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:buildsmart/state/vacation_requests.dart';
import 'package:buildsmart/state/worker_attendance.dart';
import 'package:buildsmart/state/worker_certs.dart';
import 'package:buildsmart/state/worker_forms.dart';
import 'package:buildsmart/state/worker_profile_store.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/contact_actions.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:buildsmart/widgets/photo_viewer.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🦺 WORKER PROFILE (board W, task #68) — the worker's אזור אישי: the live
/// [BoardSession] identity (displayName / username / role), honest task stats
/// derived from [tasksProvider], an entry to the worker settings (#69), the
/// code-gated 'החלפת תפקיד' row ([kRoleSwitchCode] → [showRolePicker]) and
/// 'יציאה' (boardAuth logout → every board screen rebuilds into the gate).
///
/// Rendered two ways: [embedded] as the board's 4th tab (bare body — the board
/// shell owns AppBar/nav), or pushed standalone from the worker settings.

/// Board identity → seed worker index ([kWorkers], #66): ran→0 (רן) ·
/// omer→1 (עומר). A demo session enters as רן (the seed's first worker) and is
/// marked with an honest 'דמו' chip wherever the identity shows.
/// SERVER-SWAP: becomes the server's user↔worker mapping with Firebase Auth.
int workerIndexForSession(BoardSession session) =>
    session.username == 'omer' ? 1 : 0;

/// #104ב · התמחות — ONE source of truth. טופס 101 (`worker_forms`) is the
/// form that actually collects the worker's מקצוע/התמחות, so the profile
/// DERIVES the displayed specialty from the latest saved Form101 for this
/// username rather than keeping a second, editable copy that could drift.
///
/// Fallback chain (אין המצאות — only honest, existing data):
///   1. the latest saved [Form101.specialty] for [username] (the source of
///      truth — newest year wins);
///   2. otherwise the legacy [WorkerProfile.specialty] override (a profile
///      saved before this sync — back-compat, never invented);
///   3. otherwise `''` (the UI renders nothing — honest empty state).
String workerSpecialtyOf(
  String username,
  WorkerFormsState forms,
  WorkerProfile profile,
) {
  Form101? latest;
  for (final f in forms.forms) {
    if (f.username != username) continue;
    if (f.specialty.trim().isEmpty) continue;
    if (latest == null || f.year > latest.year) latest = f;
  }
  if (latest != null) return latest.specialty.trim();
  return profile.specialty.trim();
}

class WorkerProfileScreen extends ConsumerWidget {
  const WorkerProfileScreen({this.embedded = false, super.key});

  /// True when rendered as the board's אזור-אישי tab; false when pushed
  /// standalone (its own Scaffold + "פרופיל עובד" AppBar).
  final bool embedded;

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const WorkerProfileScreen());

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔒 BOARD GATE (חוק: מבחוץ לא רואים כלום) — this is a worker-board screen:
    // without a worker session ONLY the registration gate is built (so right
    // after 'יציאה' the gate shows wherever the user is in the board stack).
    final session = ref.watch(boardAuthProvider);
    if (session == null || session.role != BoardRole.worker) {
      return WelcomeScreen(boardRole: BoardRole.worker);
    }

    final worker = workerIndexForSession(session);
    // Honest stats — derived LIVE from the worker's own tasks, no invented
    // numbers (#66: the logged worker sees only their own tasks everywhere).
    final mine =
        ref.watch(tasksProvider).where((t) => t.worker == worker).toList();
    final done = mine.where((t) => t.status == 'done').length;
    final inReview = mine.where((t) => t.status == 'review').length;
    final rejected = mine.where((t) => t.status == 'rejected').length;

    // #85ד — the worker's own editable profile (per username); every field is
    // an OVERRIDE that falls back honestly (name → session.displayName).
    final profile =
        ref.watch(workerProfileProvider)[session.username] ??
        const WorkerProfile();

    // #104ב — התמחות derived from טופס 101 (single source of truth), with the
    // legacy profile override as the honest back-compat fallback.
    final specialty = workerSpecialtyOf(
      session.username,
      ref.watch(workerFormsProvider),
      profile,
    );

    final body = ListView(
      padding: const EdgeInsets.fromLTRB(
        BsTokens.space4,
        BsTokens.space4,
        BsTokens.space4,
        BsTokens.space5,
      ),
      children: [
        _IdentityCard(session: session, profile: profile, specialty: specialty),
        const SizedBox(height: BsTokens.space3),
        _StatsCard(
          done: done,
          inReview: inReview,
          rejected: rejected,
          total: mine.length,
        ),
        const SizedBox(height: BsTokens.space4),
        // cluster #85ח — אזור אישי v2: נוכחות · טפסים · תיק בטיחות · תלושי שכר.
        // #103 — each row now carries a LIVE external status + a shortcut.
        _PersonalAreaCard(session: session),
        const SizedBox(height: BsTokens.space4),
        _ActionsCard(session: session),
      ],
    );

    if (embedded) return body;
    return Scaffold(
      backgroundColor: BsTokens.bgLight,
      appBar: AppBar(
        backgroundColor: BsTokens.cardLight,
        elevation: 0,
        title: const Text(
          'פרופיל עובד',
          style: TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black54),
      ),
      body: body,
    );
  }
}

// ─── identity card ───────────────────────────────────────────────────────────

/// White header card: avatar + the display identity — the #85ד profile
/// overrides (photo/name/phone/specialty) layered over the [BoardSession]
/// (an empty override falls back to the session — nothing invented), plus
/// the ✏️ edit action that opens the profile editor sheet.
class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.session,
    required this.profile,
    required this.specialty,
  });

  final BoardSession session;
  final WorkerProfile profile;

  /// #104ב — the התמחות DERIVED from טופס 101 (source of truth), not
  /// `profile.specialty` directly (which is only the back-compat fallback).
  final String specialty;

  @override
  Widget build(BuildContext context) {
    // #85ד — the name override falls back to the live session displayName.
    final name = profile.name.isNotEmpty ? profile.name : session.displayName;
    final meta = [
      if (specialty.isNotEmpty) '🔧 $specialty',
      if (profile.phone.isNotEmpty) '📞 ${profile.phone}',
    ].join(' · ');

    // #104ג — the expanded personal details, each shown ONLY when filled
    // (honest empty state — אין המצאות).
    final details = <(String, String)>[
      if (profile.idNumber.isNotEmpty) ('ת.ז', profile.idNumber),
      if (profile.address.isNotEmpty) ('כתובת', profile.address),
      if (profile.emergencyName.isNotEmpty || profile.emergencyPhone.isNotEmpty)
        (
          'איש קשר לחירום',
          [
            if (profile.emergencyName.isNotEmpty) profile.emergencyName,
            if (profile.emergencyPhone.isNotEmpty) profile.emergencyPhone,
          ].join(' · '),
        ),
    ];

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
              _ProfileAvatar(photo: profile.photo, size: 56),
              const SizedBox(width: BsTokens.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: const TextStyle(
                              color: BsTokens.inkLight,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        if (session.demo) ...[
                          const SizedBox(width: BsTokens.space2),
                          // Honest demo-session marker (#66).
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F3F5),
                              borderRadius: BorderRadius.circular(
                                BsTokens.radiusPill,
                              ),
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
                      '@${session.username} · עובד',
                      style: const TextStyle(
                        color: BsTokens.mutedLight,
                        fontSize: 13,
                      ),
                    ),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        meta,
                        style: const TextStyle(
                          color: BsTokens.mutedLight,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    // 📞/💬 — call or WhatsApp this worker (hidden when no phone).
                    ContactActions(phone: profile.phone),
                  ],
                ),
              ),
              // #85ד — opens the profile editor (48dp IconButton).
              HelpTarget(
                title: 'עריכת פרופיל',
                body:
                    'פותח טופס לעריכת הפרופיל שלך — שם-תצוגה, טלפון, תמונה ופרטים אישיים. '
                    'ההתמחות נגזרת אוטומטית מטופס 101.',
                child: IconButton(
                  tooltip: 'עריכת פרופיל',
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: BsTokens.mutedLight,
                  ),
                  onPressed:
                      () =>
                          showWorkerProfileEditSheet(context, session: session),
                ),
              ),
            ],
          ),
          // #104ג — the expanded personal details below the identity row,
          // each printed ONLY when filled (honest empty state).
          if (details.isNotEmpty) ...[
            const SizedBox(height: BsTokens.space3),
            const Divider(height: 1, color: Color(0xFFF2F3F5)),
            const SizedBox(height: BsTokens.space3),
            for (final (label, value) in details)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 96,
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: BsTokens.mutedLight,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        value,
                        style: const TextStyle(
                          color: BsTokens.inkLight,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// ─── task stats card ─────────────────────────────────────────────────────────

/// Honest task stats — counts derived live from [tasksProvider] (passed in).
class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.done,
    required this.inReview,
    required this.rejected,
    required this.total,
  });

  final int done;
  final int inReview;
  final int rejected;
  final int total;

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
          Row(
            children: [
              const Expanded(
                child: Text(
                  'המשימות שלי',
                  style: TextStyle(
                    color: BsTokens.inkLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                '$done/$total',
                style: const TextStyle(
                  color: BsTokens.brandDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
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
              _Stat(value: '$done', label: 'הושלמו'),
              _Stat(value: '$inReview', label: 'ממתינות לאישור'),
              _Stat(value: '$rejected', label: 'נדחו'),
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
            textAlign: TextAlign.center,
            style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ─── personal-area rows (cluster #85ח) ───────────────────────────────────────

/// A row's derived live status — the label shown on the right and the tint it
/// carries (#103). [muted] = the honest "no data yet" empty state.
class _RowStatus {
  const _RowStatus(this.label, this.color, {this.muted = false});
  final String label;
  final Color color;
  final bool muted;

  /// The honest empty-state status (grey, low-emphasis) — used when a row has
  /// no live data to surface yet (אין המצאות).
  static _RowStatus empty(String label) =>
      _RowStatus(label, BsTokens.mutedLight, muted: true);
}

/// אזור אישי v2 (#85ח) — the four personal-area entries: נוכחות (clock-in/out
/// + monthly table) · טפסים (101 / חופשה / מחלה) · תיק בטיחות (הדרכות +
/// ארנק תעודות) · תלושי שכר (SERVER-READY sheet — honest 'יחובר עם חיבור
/// השרת'). Same white-card ListTile style as [_ActionsCard]; rows are ≥48dp.
///
/// #103 — every row now shows an EXTERNAL live status derived from the
/// providers (never invented: each falls back to an honest empty state), and
/// the status itself is a tappable shortcut that jumps to the SAME destination
/// as the row (the existing navigation for that row), straight to the latest
/// update.
class _PersonalAreaCard extends ConsumerWidget {
  const _PersonalAreaCard({required this.session});

  final BoardSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username = session.username;
    final now = DateTime.now();

    // ── נוכחות — "נכנס HH:MM" (or "יצא" once clocked out) / "לא נרשם היום" ──
    // Watch the LEDGER (not `.notifier`) so a clock-in/out rebuilds the status
    // live; derive today's record with the store's own date-key helper.
    final todayKey = attendanceDateKey(now);
    final ledger = ref.watch(workerAttendanceProvider);
    AttendanceDay? today;
    for (final d in ledger) {
      if (d.username == username && d.date == todayKey) {
        today = d;
        break;
      }
    }
    final _RowStatus attendance;
    if (today?.outTs != null) {
      attendance = _RowStatus(
        'יצא ${_hhmm(today!.outTs!)}',
        BsTokens.mutedLight,
      );
    } else if (today?.inTs != null) {
      attendance = _RowStatus(
        'נכנס ${_hhmm(today!.inTs!)}',
        BsTokens.successDark,
      );
    } else {
      attendance = _RowStatus.empty('לא נרשם היום');
    }

    // ── טפסים — most actionable first: a pending vacation, then a sick note
    //    count, then the 101 submission state, else the honest empty hint. ──
    final forms = ref.watch(workerFormsProvider);
    final pendingVac = ref
        .watch(vacationRequestsProvider)
        .where(
          (r) =>
              r.username == username &&
              r.role == 'worker' &&
              r.status == kVacationPending,
        );
    final sickCount = forms.sickNotesFor(username).length;
    final form101 = forms.form101For(username, now.year);
    final _RowStatus formsStatus;
    if (pendingVac.isNotEmpty) {
      formsStatus = const _RowStatus('חופשה ⏳ ממתינה', BsTokens.warnText);
    } else if (form101?.sentTs != null) {
      formsStatus = const _RowStatus('101 הוגש ✓', BsTokens.successDark);
    } else if (form101 != null) {
      formsStatus = const _RowStatus('101 נשמר', BsTokens.brandDark);
    } else if (sickCount > 0) {
      formsStatus = _RowStatus('מחלה $sickCount', BsTokens.brandDark);
    } else {
      formsStatus = _RowStatus.empty('לא הוגשו טפסים');
    }

    // ── תיק בטיחות — certificate expiry traffic-light over the worker's wallet ──
    final certs = ref
        .watch(workerCertsProvider)
        .where((c) => c.username == username);
    final _RowStatus safety;
    if (certs.isEmpty) {
      safety = _RowStatus.empty('אין תעודות');
    } else {
      final expired =
          certs
              .where((c) => c.statusAt(now) == CertExpiryStatus.expired)
              .length;
      final soon =
          certs
              .where((c) => c.statusAt(now) == CertExpiryStatus.expiringSoon)
              .length;
      if (expired > 0) {
        safety = _RowStatus('$expired פג תוקף', BsTokens.dangerDark);
      } else if (soon > 0) {
        safety = _RowStatus('$soon לקראת תפוגה', BsTokens.warnText);
      } else {
        safety = const _RowStatus('בתוקף ✓', BsTokens.successDark);
      }
    }

    return Container(
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
        children: [
          HelpTarget(
            title: 'נוכחות',
            body:
                'פותח את לוח-הנוכחות: כניסה/יציאה ודוח חודשי. '
                'הפיל מציג את סטטוס הנוכחות החי של היום וקיצור ישיר אליו.',
            child: _PersonalAreaRow(
              emoji: '🕐',
              title: 'נוכחות',
              subtitle: 'כניסה/יציאה ודוח חודשי',
              status: attendance,
              onTap:
                  () => Navigator.of(
                    context,
                  ).push(WorkerAttendanceScreen.route()),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF2F3F5)),
          HelpTarget(
            title: 'טפסים',
            body:
                'פותח את הטפסים שלך — טופס 101, בקשת חופשה ואישור מחלה. '
                'הפיל מציג את מצב הטופס האחרון וקיצור אליו.',
            child: _PersonalAreaRow(
              emoji: '📄',
              title: 'טפסים',
              subtitle: 'טופס 101 · בקשת חופשה · אישור מחלה',
              status: formsStatus,
              onTap:
                  () => Navigator.of(context).push(WorkerFormsScreen.route()),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF2F3F5)),
          HelpTarget(
            title: 'תיק בטיחות',
            body:
                'פותח את ההדרכות והתעודות המקצועיות שלך. '
                'הפיל מציג רמזור-תוקף (פג/לקראת-תפוגה/בתוקף) וקיצור אליו.',
            child: _PersonalAreaRow(
              emoji: '🛡️',
              title: 'תיק בטיחות',
              subtitle: 'הדרכות ותעודות מקצועיות',
              status: safety,
              onTap:
                  () => Navigator.of(context).push(WorkerSafetyScreen.route()),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF2F3F5)),
          HelpTarget(
            title: 'תלושי שכר',
            body:
                'פותח את תלושי השכר. כרגע אין מקור-נתונים מקומי — '
                'המקטע מוכן לחיבור השרת.',
            child: _PersonalAreaRow(
              emoji: '💰',
              title: 'תלושי שכר',
              subtitle: 'יחובר עם חיבור השרת',
              // Honest: payslips have no on-device source yet (SERVER-READY).
              status: _RowStatus.empty('מוכן לשרת'),
              onTap: () => showWorkerPayslipsSheet(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// `HH:MM` (zero-padded, 24h) — the worker's local clock for the נוכחות status.
String _hhmm(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// One אזור-אישי row (#103): the leading emoji · title/subtitle · a live status
/// pill that is ITSELF a shortcut (taps run [onTap] — the same destination the
/// whole row navigates to, jumping straight to the latest update for that area).
class _PersonalAreaRow extends StatelessWidget {
  const _PersonalAreaRow({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final _RowStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(emoji, style: const TextStyle(fontSize: 20)),
      title: Text(
        title,
        style: const TextStyle(color: BsTokens.inkLight, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The status is a tappable shortcut to the latest update (same
          // destination as the row). ≥48dp tap target via the pill padding.
          Semantics(
            button: true,
            label: '${status.label} — פתח $title',
            excludeSemantics: true,
            child: Material(
              color:
                  status.muted
                      ? const Color(0xFFF2F3F5)
                      : status.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
              child: InkWell(
                borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                onTap: onTap,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 32),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  child: Text(
                    status.label,
                    style: TextStyle(
                      color: status.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_left, color: BsTokens.mutedLight),
        ],
      ),
      onTap: onTap,
    );
  }
}

// ─── actions card ────────────────────────────────────────────────────────────

/// Settings entry (#69) · code-gated role switch (#68) · logout (#68).
class _ActionsCard extends ConsumerWidget {
  const _ActionsCard({required this.session});

  final BoardSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
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
        children: [
          HelpTarget(
            title: 'הגדרות עובד',
            body:
                'פותח את הגדרות הלוח המותאמות לעובד — התראות, אזור ושפה, '
                'ממשק ונגישות ומידע משפטי.',
            child: ListTile(
              leading: const Text('⚙️', style: TextStyle(fontSize: 20)),
              title: const Text(
                'הגדרות עובד',
                style: TextStyle(color: BsTokens.inkLight, fontSize: 15),
              ),
              trailing: const Icon(
                Icons.chevron_left,
                color: BsTokens.mutedLight,
              ),
              onTap:
                  () =>
                      Navigator.of(context).push(WorkerSettingsScreen.route()),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF2F3F5)),
          HelpTarget(
            title: 'החלפת תפקיד',
            body:
                'מעבר ללוח אחר (קבלן/מנהל/חנות/שליח) — מוגן בקוד. '
                'ללא הקוד הנכון המעבר אינו מתאפשר.',
            child: ListTile(
              leading: const Text('🔄', style: TextStyle(fontSize: 20)),
              title: const Text(
                'החלפת תפקיד',
                style: TextStyle(color: BsTokens.inkLight, fontSize: 15),
              ),
              subtitle: const Text(
                'מוגן בקוד',
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
              ),
              trailing: const Icon(
                Icons.chevron_left,
                color: BsTokens.mutedLight,
              ),
              onTap: () => _askRoleSwitchCode(context),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF2F3F5)),
          HelpTarget(
            title: 'יציאה',
            body:
                'מנתק אותך מלוח העובד ומחזיר למסך ההרשמה. '
                'תתבקש לאשר לפני הניתוק.',
            child: ListTile(
              leading: const Text('🚪', style: TextStyle(fontSize: 20)),
              title: const Text(
                'יציאה',
                // AA: redAccent על לבן נכשל — token חוזה 9.
                style: TextStyle(color: BsTokens.dangerDark, fontSize: 15),
              ),
              onTap: () => _logout(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  /// #68 — the role switch is gated behind [kRoleSwitchCode]: a code dialog,
  /// honest 'קוד שגוי' on a wrong entry, [showRolePicker] on success.
  Future<void> _askRoleSwitchCode(BuildContext context) async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        String? error;
        // F-46: בוני-מסלול modal אינם יורשים את עטיפת ה-RTL ברמת-האפליקציה.
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (ctx, setState) {
              void submit() {
                // Validated against the local seed code — SERVER-SWAP: becomes a
                // server-side permission check with Firebase Auth.
                if (controller.text.trim() == kRoleSwitchCode) {
                  Navigator.pop(dialogCtx, true);
                } else {
                  setState(() => error = 'קוד שגוי — נסה שוב');
                }
              }

              return AlertDialog(
                backgroundColor: const Color(0xFFFFFFFF),
                title: const Text(
                  'החלפת תפקיד',
                  style: TextStyle(color: BsTokens.inkLight),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'מעבר בין לוחות מוגן בקוד. הזן את קוד החלפת התפקיד:',
                      style: TextStyle(color: Colors.black54, fontSize: 13.5),
                    ),
                    const SizedBox(height: BsTokens.space3),
                    TextField(
                      controller: controller,
                      autofocus: true,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      onSubmitted: (_) => submit(),
                      decoration: InputDecoration(
                        // תווית נראית גם בזמן הקלדה (לא hint חולף בלבד).
                        labelText: 'קוד מעבר',
                        hintText: 'קוד',
                        errorText: error,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogCtx, false),
                    child: const Text('ביטול'),
                  ),
                  TextButton(onPressed: submit, child: const Text('אישור')),
                ],
              );
            },
          ),
        );
      },
    );
    controller.dispose();
    if ((ok ?? false) && context.mounted) {
      await showRolePicker(context);
    }
  }

  /// #68 — 'יציאה': confirm, then boardAuth logout. No navigation needed —
  /// every worker-board screen watches [boardAuthProvider] and rebuilds into
  /// the registration gate on its own.
  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final ok = await confirmDestructive(
      context,
      title: 'יציאה מהחשבון?',
      message: 'תנותק מלוח העובד ותחזור למסך ההרשמה.',
      confirmLabel: 'התנתק',
    );
    if (!ok || !context.mounted) return;
    ref.read(boardAuthProvider.notifier).logout();
  }
}

// ─── #85ד · editable profile ─────────────────────────────────────────────────

/// The profile avatar — the saved photo (data-URL → [Image.memory]) clipped
/// to a circle, or the default 🦺 emoji disc when no photo is set.
class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.photo, required this.size});

  final String? photo;
  final double size;

  @override
  Widget build(BuildContext context) {
    // Dual-render (A14): a base64 data-URL decodes locally; an uploaded
    // `https://…` URL (kCloudPhotos ON) streams from R2 — both via the single
    // [imageProviderForRef] helper. No photo / malformed → the default avatar.
    final provider = imageProviderForRef(photo);
    if (provider != null) {
      return ClipOval(
        child: Image(
          image: provider,
          width: size,
          height: size,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          // A corrupt payload / failed fetch renders the default avatar.
          errorBuilder: (_, __, ___) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      color: Color(0xFFFFF0E3),
      shape: BoxShape.circle,
    ),
    // Decorative: the full name is read just beside it.
    child: ExcludeSemantics(
      child: Text('🦺', style: TextStyle(fontSize: size * 0.46)),
    ),
  );
}

/// #85ד — opens the worker profile editor (modal bottom sheet, X to close).
Future<void> showWorkerProfileEditSheet(
  BuildContext context, {
  required BoardSession session,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _EditProfileSheet(session: session),
  );
}

/// The profile editor — שם-תצוגה · טלפון · התמחות (chips) · תמונת-פרופיל (the
/// shared [pickTaskPhoto] capture seam, #85ב). Saved per username through
/// [workerProfileProvider] (key `bs.worker-profile.v1`); every empty field
/// keeps its honest fallback (name → session displayName, no photo → 🦺).
class _EditProfileSheet extends ConsumerStatefulWidget {
  const _EditProfileSheet({required this.session});

  final BoardSession session;

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  // #104ג — extra personal details (all optional except the phone, which is
  // now REQUIRED). ת.ז · כתובת · איש-קשר-לחירום (שם + טלפון).
  late final TextEditingController _idNumber;
  late final TextEditingController _address;
  late final TextEditingController _emName;
  late final TextEditingController _emPhone;
  String? _photo;
  String? _phoneError;
  String? _idError;
  String? _emPhoneError;

  /// מגן in-flight: double-tap על "שמור" לא מריץ save כפול / pop כפול.
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p =
        ref.read(workerProfileProvider)[widget.session.username] ??
        const WorkerProfile();
    _name = TextEditingController(
      text: p.name.isNotEmpty ? p.name : widget.session.displayName,
    );
    _phone = TextEditingController(text: p.phone);
    _idNumber = TextEditingController(text: p.idNumber);
    _address = TextEditingController(text: p.address);
    _emName = TextEditingController(text: p.emergencyName);
    _emPhone = TextEditingController(text: p.emergencyPhone);
    _photo = p.photo;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _idNumber.dispose();
    _address.dispose();
    _emName.dispose();
    _emPhone.dispose();
    super.dispose();
  }

  /// Real capture via the shared seam — null = honest cancel, no change.
  Future<void> _pickPhoto() async {
    final dataUrl = await pickTaskPhoto(context);
    if (!mounted) return;
    if (dataUrl == null) {
      showToast(context, 'לא נבחרה תמונה');
      return;
    }
    setState(() => _photo = dataUrl);
  }

  Future<void> _save() async {
    if (_saving) return; // מגן double-tap (in-flight)
    final phone = _phone.text.trim();
    final idDigits = _idNumber.text.replaceAll(RegExp(r'[\s-]'), '');
    final emPhone = _emPhone.text.trim();
    // FORMAT validation (the #64 validators), gathered so EVERY bad field is
    // marked at once — not one-at-a-time.
    final phoneErr =
        phone.isEmpty
            // #104א — the phone is now REQUIRED (no longer optional).
            ? 'נא למלא מספר נייד'
            : (!validIsraeliMobile(phone)
                ? 'מספר נייד לא תקין — 10 ספרות, מתחיל ב-05'
                : null);
    // #104ג — ת.ז is optional, but a non-empty value must be 9 digits
    // (FORMAT only — a real checksum/identity check is a server concern).
    final idErr =
        idDigits.isNotEmpty && !RegExp(r'^\d{9}$').hasMatch(idDigits)
            ? 'ת.ז חייבת להיות 9 ספרות'
            : null;
    // #104ג — the emergency phone is optional, but a non-empty value must be
    // a valid Israeli mobile.
    final emPhoneErr =
        emPhone.isNotEmpty && !validIsraeliMobile(emPhone)
            ? 'מספר נייד לא תקין — 10 ספרות, מתחיל ב-05'
            : null;
    if (phoneErr != null || idErr != null || emPhoneErr != null) {
      setState(() {
        _phoneError = phoneErr;
        _idError = idErr;
        _emPhoneError = emPhoneErr;
      });
      return;
    }
    setState(() => _saving = true);
    final name = _name.text.trim();
    // #104ב — התמחות is NOT edited here (טופס 101 owns it). Preserve the
    // worker's existing legacy override verbatim so the back-compat fallback
    // is never clobbered to '' by a profile save.
    final existing =
        ref.read(workerProfileProvider)[widget.session.username] ??
        const WorkerProfile();
    // #17 — the persist is AWAITED: a quota failure (an oversized photo on
    // web localStorage) reports honestly instead of a fake '✓ נשמר'.
    final ok = await ref
        .read(workerProfileProvider.notifier)
        .save(
          widget.session.username,
          WorkerProfile(
            // Storing '' keeps the honest fallback to the session displayName.
            name: name == widget.session.displayName ? '' : name,
            phone: phone,
            specialty: existing.specialty,
            photo: _photo,
            // Store the normalized 9-digit ת.ז (or '' when left empty).
            idNumber: idDigits,
            address: _address.text.trim(),
            emergencyName: _emName.text.trim(),
            emergencyPhone: emPhone,
          ),
        );
    if (!mounted) return;
    if (!ok) {
      setState(() => _saving = false); // מאפשר retry עם תמונה קטנה יותר
      showToast(context, 'התמונה גדולה מדי — לא נשמרה');
      return; // the sheet stays open — the worker can retry a smaller photo
    }
    showToast(context, '✓ הפרופיל נשמר');
    Navigator.of(context).pop();
  }

  /// A labelled text field for the sheet (≥48dp via the default TextField
  /// height) — clears its [errorText] live on edit when [onClearError] given.
  Widget _sheetField(
    TextEditingController ctl,
    String label, {
    String? errorText,
    String? hintText,
    TextInputType? keyboardType,
    VoidCallback? onClearError,
    TextInputAction textInputAction = TextInputAction.next,
    // LTR for digit/phone/number fields (phone, ת.ז) so latin digits render
    // left-to-right under the sheet's RTL Directionality; default stays RTL.
    bool ltr = false,
  }) {
    return TextField(
      controller: ctl,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textDirection: ltr ? TextDirection.ltr : null,
      onChanged: onClearError == null ? null : (_) => onClearError(),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        errorText: errorText,
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // #104ב — התמחות is DERIVED from טופס 101 (single source of truth); the
    // sheet only DISPLAYS it (read-only) and points the worker to 101 to
    // change it — no second editable copy that could drift.
    final specialty = workerSpecialtyOf(
      widget.session.username,
      ref.watch(workerFormsProvider),
      ref.watch(workerProfileProvider)[widget.session.username] ??
          const WorkerProfile(),
    );
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        // Keep the fields above the keyboard.
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: BsTokens.cardLight,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(BsTokens.radiusCard),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(BsTokens.space4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'עריכת פרופיל',
                          style: TextStyle(
                            color: BsTokens.inkLight,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      // X close (sheet rule).
                      IconButton(
                        tooltip: 'סגור',
                        icon: const Icon(
                          Icons.close,
                          color: BsTokens.mutedLight,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: BsTokens.space2),
                  // ── profile photo (#85ד, the #85ב capture seam) ──
                  Row(
                    children: [
                      _ProfileAvatar(photo: _photo, size: 64),
                      const SizedBox(width: BsTokens.space3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            OutlinedButton(
                              onPressed: _pickPhoto,
                              child: Text(
                                _photo == null
                                    ? '📷 הוסף תמונת פרופיל'
                                    : '📷 החלף תמונה',
                              ),
                            ),
                            if (_photo != null)
                              TextButton(
                                onPressed: () => setState(() => _photo = null),
                                child: const Text(
                                  'הסר תמונה',
                                  // AA: redAccent על לבן נכשל — token חוזה 9.
                                  style: TextStyle(color: BsTokens.dangerDark),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: BsTokens.space3),
                  // ── display name ──
                  TextField(
                    controller: _name,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'שם תצוגה',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: BsTokens.space3),
                  // ── phone (#104א — REQUIRED) ──
                  _sheetField(
                    _phone,
                    'טלפון נייד',
                    hintText: '050-1234567',
                    keyboardType: TextInputType.phone,
                    ltr: true,
                    errorText: _phoneError,
                    onClearError: () {
                      if (_phoneError != null) {
                        setState(() => _phoneError = null);
                      }
                    },
                  ),
                  const SizedBox(height: BsTokens.space3),
                  // ── ת.ז (#104ג — optional, 9-digit FORMAT) ──
                  _sheetField(
                    _idNumber,
                    'תעודת זהות (9 ספרות)',
                    keyboardType: TextInputType.number,
                    ltr: true,
                    errorText: _idError,
                    onClearError: () {
                      if (_idError != null) {
                        setState(() => _idError = null);
                      }
                    },
                  ),
                  const SizedBox(height: BsTokens.space3),
                  // ── address (#104ג) ──
                  _sheetField(_address, 'כתובת'),
                  const SizedBox(height: BsTokens.space3),
                  // ── specialty — DERIVED from טופס 101 (#104ב, read-only) ──
                  _SpecialtyDerivedRow(specialty: specialty),
                  const SizedBox(height: BsTokens.space4),
                  // ── emergency contact (#104ג) ──
                  const Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      'איש קשר לחירום',
                      style: TextStyle(
                        color: BsTokens.inkLight,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: BsTokens.space2),
                  _sheetField(_emName, 'שם'),
                  const SizedBox(height: BsTokens.space3),
                  _sheetField(
                    _emPhone,
                    'טלפון',
                    hintText: '050-1234567',
                    keyboardType: TextInputType.phone,
                    ltr: true,
                    errorText: _emPhoneError,
                    textInputAction: TextInputAction.done,
                    onClearError: () {
                      if (_emPhoneError != null) {
                        setState(() => _emPhoneError = null);
                      }
                    },
                  ),
                  const SizedBox(height: BsTokens.space4),
                  // ── save ──
                  Material(
                    color: BsTokens.brand,
                    borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                      onTap: _saving ? null : _save,
                      child: Opacity(
                        opacity: _saving ? 0.6 : 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          child: Text(
                            '✓ שמור פרופיל',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: bsOnAccent(context),
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// #104ב — the התמחות panel inside the edit sheet. READ-ONLY: טופס 101 is the
/// single source of truth, so the worker changes their התמחות there (the
/// 'מקצוע / התמחות' field), not here. Shows the derived value, or an honest
/// empty hint when none was filled in 101 yet — never an editable duplicate.
class _SpecialtyDerivedRow extends StatelessWidget {
  const _SpecialtyDerivedRow({required this.specialty});

  final String specialty;

  @override
  Widget build(BuildContext context) {
    final has = specialty.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: BsTokens.bgLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E2E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔧', style: TextStyle(fontSize: 16)),
              const SizedBox(width: BsTokens.space2),
              const Text(
                'התמחות',
                style: TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  has ? specialty : 'לא הוגדרה',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: has ? BsTokens.inkLight : BsTokens.mutedLight,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Honest pointer to the single source of truth (no second editor).
          const Text(
            'נערך בטופס 101 (מקצוע / התמחות)',
            style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
