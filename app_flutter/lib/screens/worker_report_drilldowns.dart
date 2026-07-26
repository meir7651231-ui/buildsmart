// 🔎 דוחות v2 — drill-downs (#109). Every dead summary section in
// `worker_reports_tab.dart` becomes tappable → one of the RTL sheets below,
// each showing REAL live data for the logged worker (#66 — own tasks only):
//   ① KPI boxes  → first-pass (done-vs-rejected) · BuildCoins breakdown ·
//                  streak (contributing completed tasks).
//   ② week bar   → that calendar day's clocked tasks.
//   ③ time row   → one task's full time detail (start/finish/elapsed).
//   ④ area row   → the tasks grouped under that work area.
//   ⑤ history row→ a submission detail (status · note · timing · proof).
//   ⑥ reject row → the manager's reason + the task.
//
// אין המצאות: every figure is read live from [tasksProvider] /
// [rewardsProvider] / the bs.* side-maps that the tab already imports. Where the
// engine has no data the sheet prints an honest empty line instead of inventing.
// These openers are pure presentation — they never mutate a provider.
//
// SOLE OWNER: Builder-C (#109), same as worker_reports_tab.dart. This file adds
// NO new public provider/engine surface; it only consumes the existing one.

import 'package:buildsmart/config/app_brand.dart';
import 'package:buildsmart/data/persona_data.dart';
import 'package:buildsmart/screens/worker_reports_tab.dart';
import 'package:buildsmart/state/org_gates.dart' show orgTermNow;
import 'package:buildsmart/state/rewards_state.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/photo_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── shared sheet chrome ──────────────────────────────────────────────────────

/// Hebrew month-day stamp, e.g. 14.6.2026 — used by the day/time/submission
/// detail sheets (no invented formatting: plain numeric date).
String _fmtDate(DateTime d) => '${d.day}.${d.month}.${d.year}';

String _hhmm(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

String fmtDurationReport(Duration d) {
  if (d.inMinutes < 1) return 'פחות מדקה';
  if (d.inHours < 1) return '${d.inMinutes} דק׳';
  if (d.inDays < 1) {
    final m = d.inMinutes % 60;
    return m == 0 ? '${d.inHours} שע׳' : '${d.inHours} שע׳ $m דק׳';
  }
  final h = d.inHours % 24;
  return h == 0 ? '${d.inDays} ימים' : '${d.inDays} ימים $h שע׳';
}

/// The single RTL modal-sheet scaffold every drill-down uses: a forced
/// [TextDirection.rtl], a bold title row with a ≥48dp ✕ close, then [children]
/// in a scroll view (sheets never overflow on a long task list).
Future<void> _showReportSheet(
  BuildContext context, {
  required String title,
  required List<Widget> children,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: BsTokens.cardLight,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(BsTokens.space4)),
    ),
    builder: (sheetCtx) => Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            BsTokens.space4,
            BsTokens.space2,
            BsTokens.space4,
            BsTokens.space4,
          ),
          child: ConstrainedBox(
            // Cap the sheet so a long list scrolls inside instead of pushing
            // the close button off-screen.
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetCtx).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: BsTokens.inkLight,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    // ≥48dp explicit close (sheet rule).
                    Semantics(
                      button: true,
                      label: 'סגור',
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.of(sheetCtx).pop(),
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
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: children,
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

/// Honest empty line — every sheet falls back to this when the live query has
/// nothing (no invented placeholder rows).
Widget _emptyLine(String text) => Padding(
      padding: const EdgeInsets.symmetric(vertical: BsTokens.space2),
      child: Text(
        text,
        style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13.5),
      ),
    );

/// A muted disclaimer footer (carried verbatim from the tab where required, e.g.
/// the work-area derivation note).
Widget _disclaimer(String text) => Padding(
      padding: const EdgeInsets.only(top: BsTokens.space2),
      child: Text(
        text,
        style: const TextStyle(color: BsTokens.mutedLight, fontSize: 11.5),
      ),
    );

/// One task line inside a drill-down: name + the verbatim status pill, with the
/// inner label excluded from semantics where the row's own Semantics repeats it.
Widget _taskLine(TaskItem t, {String? trailing}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: BsTokens.space2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.name,
                style: const TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(height: 3),
              _MiniStatusPill(status: t.status),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: BsTokens.space2),
          Text(
            trailing,
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ],
      ],
    ),
  );
}

// ─── ① KPI drill-downs ────────────────────────────────────────────────────────

/// first-pass% box → the done-vs-rejected reality behind the percentage. Reads
/// [tasksProvider] (this worker) + [taskRejectionLogProvider] (ever-rejected
/// log) live, so a resubmit-then-approved task is correctly shown as NOT
/// first-pass.
Future<void> showFirstPassDrilldown(
  BuildContext context,
  WidgetRef ref, {
  required int worker,
}) {
  final mine =
      ref.read(tasksProvider).where((t) => t.worker == worker).toList();
  final everRejected = ref.read(taskRejectionLogProvider);
  final submitted = mine
      .where((t) =>
          t.status == 'review' || t.status == 'done' || t.status == 'rejected')
      .toList();
  final doneClean = mine
      .where((t) => t.status == 'done' && !everRejected.contains(t.id))
      .toList();
  final doneAfterReject = mine
      .where((t) => t.status == 'done' && everRejected.contains(t.id))
      .toList();
  final rejected = mine.where((t) => t.status == 'rejected').toList();

  return _showReportSheet(
    context,
    title: '🎯 אישור-ראשון — פירוט',
    children: [
      if (submitted.isEmpty)
        _emptyLine('עוד אין הגשות — משימה שתוגש לאישור תופיע כאן.')
      else ...[
        _GroupHeader(
            '✅ אושרו ללא דחייה (${doneClean.length}/${submitted.length})'),
        if (doneClean.isEmpty)
          _emptyLine('אין עדיין משימות שאושרו בלי דחייה.')
        else
          for (final t in doneClean) _taskLine(t),
        if (doneAfterReject.isNotEmpty) ...[
          const SizedBox(height: BsTokens.space2),
          _GroupHeader('🔁 אושרו אחרי תיקון (${doneAfterReject.length})'),
          for (final t in doneAfterReject) _taskLine(t),
        ],
        if (rejected.isNotEmpty) ...[
          const SizedBox(height: BsTokens.space2),
          _GroupHeader('↩️ ממתינות לתיקון (${rejected.length})'),
          for (final t in rejected) _taskLine(t),
        ],
        _disclaimer(
          'אישור-ראשון = הגשות שאושרו בלי דחייה אף פעם, מתוך כלל ההגשות. '
          'משימה שנדחתה פעם אחת ואז אושרה אינה נספרת כאישור-ראשון.',
        ),
      ],
    ],
  );
}

/// BuildCoins box → the rewards breakdown. KEEPS the honest device-shared
/// framing (#F-33): the balance is the whole device's BuildSmart club overlay,
/// NOT a per-worker ledger. Shows the live balance, the current VIP tier, and
/// the open monthly challenges — all from [rewardsProvider].
Future<void> showCoinsDrilldown(BuildContext context, WidgetRef ref) {
  final rewards = ref.read(rewardsProvider);
  final tier = rewards.currentTier;
  return _showReportSheet(
    context,
    title: '🪙 BuildCoins — מועדון משותף',
    children: [
      _KvLine(label: 'מאזן נוכחי', value: '${rewards.coins} 🪙'),
      _KvLine(label: 'דרגת מועדון', value: tier.name),
      Padding(
        padding: const EdgeInsets.only(top: 2, bottom: BsTokens.space2),
        child: Text(
          tier.perks,
          style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12),
        ),
      ),
      const SizedBox(height: BsTokens.space1),
      _GroupHeader('🎯 אתגרים חודשיים פתוחים (${rewards.challenges.length})'),
      if (rewards.challenges.isEmpty)
        _emptyLine('אין אתגרים פתוחים — כולם הושלמו או נוצלו.')
      else
        for (final c in rewards.challenges)
          _KvLine(
            label: c.name,
            value: c.done
                ? 'הושלם · +${c.reward} 🪙'
                : '${c.progress}/${c.goal} · +${c.reward} 🪙',
          ),
      _disclaimer(
        'מאזן המטבעות הוא מאזן ${orgTermNow(ref, 'brand.club', AppBrand.club)} המשותף לכל התפקידים במכשיר הזה '
        '(bs.rewards.v1) — אינו נצבר לעובד בנפרד. ניהול נקודות per-עובד יחובר עם '
        'חיבור השרת.',
      ),
    ],
  );
}

/// streak box → the completed tasks whose clock stamps land on the consecutive
/// activity days ending today. Reads the engine's own [TaskItem.startedAt] /
/// [completedAt] (the same source the streak figure is computed from in the
/// tab), so the list is exactly the evidence behind the number.
Future<void> showStreakDrilldown(
  BuildContext context,
  WidgetRef ref, {
  required int worker,
}) {
  final mine =
      ref.read(tasksProvider).where((t) => t.worker == worker).toList();

  // The set of calendar days this worker has any clock stamp on (mirrors the
  // tab's streak computation).
  final activityDays = <DateTime>{};
  for (final t in mine) {
    for (final ts in [t.startedAt, t.completedAt]) {
      if (ts != null) activityDays.add(DateTime(ts.year, ts.month, ts.day));
    }
  }
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  var streak = 0;
  while (activityDays
      .contains(DateTime(today.year, today.month, today.day - streak))) {
    streak++;
  }
  // The window of days that make up the current streak.
  final streakDays = {
    for (var i = 0; i < streak; i++)
      DateTime(today.year, today.month, today.day - i),
  };
  // Tasks that contributed a stamp inside the streak window.
  final contributing = [
    for (final t in mine)
      if ([t.startedAt, t.completedAt].any((ts) =>
          ts != null && streakDays.contains(DateTime(ts.year, ts.month, ts.day))))
        t,
  ];

  return _showReportSheet(
    context,
    title: '🔥 רצף פעילות — פירוט',
    children: [
      if (activityDays.isEmpty)
        _emptyLine(
            'אין עדיין פעילות מתוזמנת — הרצף נמדד מימים רצופים עם שעון משימות פעיל.')
      else ...[
        _KvLine(
          label: 'רצף נוכחי',
          value: streak == 1 ? 'יום אחד' : '$streak ימים',
        ),
        const SizedBox(height: BsTokens.space1),
        _GroupHeader('משימות תורמות לרצף (${contributing.length})'),
        if (contributing.isEmpty)
          _emptyLine('אין משימות עם חותמת-זמן בחלון הרצף הנוכחי.')
        else
          for (final t in contributing)
            _taskLine(
              t,
              trailing: t.completedAt != null
                  ? _fmtDate(t.completedAt!)
                  : (t.startedAt != null ? _fmtDate(t.startedAt!) : null),
            ),
        _disclaimer(
          'הרצף נמדד משעון המשימות — ימים רצופים (עד היום) שבהם יש חותמת התחלה או '
          'אישור למשימה שלך.',
        ),
      ],
    ],
  );
}

// ─── ② week bar drill-down ────────────────────────────────────────────────────

/// A tapped week bar → that day's clocked tasks. [day] is the calendar day the
/// bar represents; the sheet lists this worker's tasks whose clock has a
/// startedAt OR completedAt on that day (from [taskClockProvider]).
Future<void> showWeekDayDrilldown(
  BuildContext context,
  WidgetRef ref, {
  required int worker,
  required DateTime day,
}) {
  final mine =
      ref.read(tasksProvider).where((t) => t.worker == worker).toList();
  final clock = ref.read(taskClockProvider).asData?.value ??
      const <int, TaskClockEntry>{};
  bool onDay(DateTime? ts) =>
      ts != null &&
      ts.year == day.year &&
      ts.month == day.month &&
      ts.day == day.day;

  final approved = <TaskItem>[];
  final started = <TaskItem>[];
  for (final t in mine) {
    final e = clock[t.id];
    if (e == null) continue;
    if (onDay(e.completedAt)) {
      approved.add(t);
    } else if (onDay(e.startedAt)) {
      started.add(t);
    }
  }

  return _showReportSheet(
    context,
    title: '📅 ${_fmtDate(day)} — פעילות היום',
    children: [
      if (approved.isEmpty && started.isEmpty)
        _emptyLine('אין משימות עם חותמת-זמן ביום הזה.')
      else ...[
        if (approved.isNotEmpty) ...[
          _GroupHeader('✅ אושרו היום (${approved.length})'),
          for (final t in approved)
            _taskLine(
              t,
              trailing: clock[t.id]?.completedAt != null
                  ? _hhmm(clock[t.id]!.completedAt!)
                  : null,
            ),
        ],
        if (started.isNotEmpty) ...[
          if (approved.isNotEmpty) const SizedBox(height: BsTokens.space2),
          _GroupHeader('🔨 נפתחו לעבודה היום (${started.length})'),
          for (final t in started)
            _taskLine(
              t,
              trailing: clock[t.id]?.startedAt != null
                  ? _hhmm(clock[t.id]!.startedAt!)
                  : null,
            ),
        ],
      ],
    ],
  );
}

// ─── ③ time-per-task drill-down ───────────────────────────────────────────────

/// One time row → that task's full time detail: start, finish, and the measured
/// elapsed time (or the live "running since" when still open). Reads the clock
/// entry live so an open task's figure is current.
Future<void> showTaskTimeDrilldown(
  BuildContext context,
  WidgetRef ref, {
  required TaskItem task,
}) {
  final clock = ref.read(taskClockProvider).asData?.value ??
      const <int, TaskClockEntry>{};
  final e = clock[task.id];
  final started = e?.startedAt;
  final completed = e?.completedAt;
  final dur = e?.duration;

  return _showReportSheet(
    context,
    title: '⏱️ ${task.name}',
    children: [
      _KvLine(label: 'סטטוס', value: kTaskStatusLabel[task.status] ?? task.status),
      if (started != null)
        _KvLine(
          label: 'התחלה',
          value: '${_fmtDate(started)} · ${_hhmm(started)}',
        )
      else
        _emptyLine('אין חותמת התחלה — המשימה נפתחה לפני הפעלת שעון המשימות.'),
      if (completed != null)
        _KvLine(
          label: 'אישור',
          value: '${_fmtDate(completed)} · ${_hhmm(completed)}',
        ),
      if (dur != null)
        _KvLine(label: 'משך כולל', value: fmtDurationReport(dur))
      else if (started != null && completed == null)
        _KvLine(
          label: 'משך עד כה',
          value: fmtDurationReport(DateTime.now().difference(started)),
        ),
      if (task.note.isNotEmpty) ...[
        const SizedBox(height: BsTokens.space1),
        _GroupHeader('📝 הערת עובד'),
        Text(
          '"${task.note}"',
          style: const TextStyle(color: BsTokens.inkLight, fontSize: 13),
        ),
      ],
      _disclaimer(
        'הזמן נמדד אוטומטית מרגע "התחל עבודה" ועד אישור המשימה.',
      ),
    ],
  );
}

// ─── ④ work-area drill-down ───────────────────────────────────────────────────

/// One work-area row → the tasks grouped under that area. KEEPS the verbatim
/// 'האזור נגזר משם המשימה' disclaimer (the engine has no site field). [area] is
/// the [taskWorkArea] key; tasks are re-derived live from [tasksProvider].
Future<void> showAreaDrilldown(
  BuildContext context,
  WidgetRef ref, {
  required int worker,
  required String area,
}) {
  final tasks = ref
      .read(tasksProvider)
      .where((t) => t.worker == worker && taskWorkArea(t.name) == area)
      .toList();

  return _showReportSheet(
    context,
    title: '📍 $area',
    children: [
      if (tasks.isEmpty)
        _emptyLine('אין משימות באזור הזה.')
      else
        for (final t in tasks) _taskLine(t),
      _disclaimer(
        'האזור נגזר משם המשימה (אין שדה אתר במנוע המשימות). שיוך לאתרי פרויקט '
        'אמיתיים יחובר עם חיבור השרת.',
      ),
    ],
  );
}

// ─── ⑤ submission-detail drill-down ───────────────────────────────────────────

/// A history-row body → the submission detail: status, the worker's note, the
/// measured timing, and the proof photo (the existing full-screen viewer is
/// still reachable from the row thumbnail; here we surface a tappable enlarge
/// when a real data-URL photo exists). [duration] is the clock-measured span
/// passed by the row (already computed in the tab).
Future<void> showSubmissionDrilldown(
  BuildContext context, {
  required TaskItem task,
  Duration? duration,
}) {
  final bytes = decodeDataUrlPhoto(task.photo);
  return _showReportSheet(
    context,
    title: '📋 ${task.name}',
    children: [
      _KvLine(label: 'סטטוס', value: kTaskStatusLabel[task.status] ?? task.status),
      if (duration != null)
        _KvLine(label: 'משך מדוד', value: fmtDurationReport(duration)),
      const SizedBox(height: BsTokens.space1),
      _GroupHeader('📝 הערת עובד'),
      if (task.note.isNotEmpty)
        Text(
          '"${task.note}"',
          style: const TextStyle(color: BsTokens.inkLight, fontSize: 13),
        )
      else
        _emptyLine('לא צורפה הערה להגשה.'),
      const SizedBox(height: BsTokens.space2),
      _GroupHeader('📷 תמונת הוכחה'),
      if (bytes != null)
        Semantics(
          button: true,
          label: 'הצג תמונת הוכחה במסך מלא',
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => showFullPhotoDialog(context, bytes, label: task.name),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                bytes,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                cacheWidth:
                    (360 * MediaQuery.devicePixelRatioOf(context)).round(),
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) =>
                    _emptyLine('📷 לא ניתן להציג את התמונה.'),
              ),
            ),
          ),
        )
      else
        _emptyLine(task.photo == null
            ? 'לא צורפה תמונה (או שהוסרה בעת דחייה).'
            : 'תמונת דמו — אין קובץ אמיתי להצגה.'),
    ],
  );
}

// ─── ⑥ rejection drill-down ───────────────────────────────────────────────────

/// A rejection row → the manager's reason + the task. Reads
/// [taskRejectNotesProvider] live; honest fallback when no reason was stored.
Future<void> showRejectionDrilldown(
  BuildContext context,
  WidgetRef ref, {
  required TaskItem task,
}) {
  final notes = ref.read(taskRejectNotesProvider).asData?.value ??
      const <int, String>{};
  final reason = notes[task.id];
  return _showReportSheet(
    context,
    title: '↩️ ${task.name}',
    children: [
      _KvLine(label: 'סטטוס', value: kTaskStatusLabel[task.status] ?? task.status),
      const SizedBox(height: BsTokens.space1),
      _GroupHeader('סיבת המנהל'),
      if (reason != null)
        Text(
          '"$reason"',
          style: const TextStyle(color: BsTokens.inkLight, fontSize: 13.5),
        )
      else
        _emptyLine('המנהל לא צירף סיבה לדחייה.'),
      if (task.detail.isNotEmpty) ...[
        const SizedBox(height: BsTokens.space2),
        _GroupHeader('פירוט המשימה'),
        Text(
          task.detail,
          style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
        ),
      ],
      _disclaimer(
        'צלם שוב ושלח לאישור כדי לתקן — הדחייה נשמרת ביומן עד לאישור.',
      ),
    ],
  );
}

// ─── small shared widgets ─────────────────────────────────────────────────────

/// A bold sub-section header inside a sheet.
class _GroupHeader extends StatelessWidget {
  const _GroupHeader(this.text);

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
          fontSize: 13.5,
        ),
      ),
    );
  }
}

/// Label ↔ value row inside a sheet (RTL-safe). [excludeSemantics] is on so the
/// flattened "label value" string is read once, not twice.
class _KvLine extends StatelessWidget {
  const _KvLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Semantics(
        label: '$label: $value',
        child: ExcludeSemantics(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  style:
                      const TextStyle(color: BsTokens.mutedLight, fontSize: 13),
                ),
              ),
              const SizedBox(width: BsTokens.space2),
              Text(
                value,
                style: const TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact status pill (the verbatim [kTaskStatusLabel] over a status tint) —
/// the drill-down twin of the tab's `_StatusPill`.
class _MiniStatusPill extends StatelessWidget {
  const _MiniStatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      'done' => (const Color(0xFFD7F5DF), const Color(0xFF1F8A4C)),
      'rejected' => (const Color(0xFFFFE4E4), const Color(0xFFB42318)),
      'review' => (const Color(0xFFFFF0E3), BsTokens.brandDark),
      'active' => (const Color(0xFFE3F0FF), const Color(0xFF1D5FB5)),
      _ => (const Color(0xFFF0F0F0), BsTokens.mutedLight), // pending
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      ),
      child: Text(
        kTaskStatusLabel[status] ?? status,
        style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 11),
      ),
    );
  }
}
