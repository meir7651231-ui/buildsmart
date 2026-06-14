// Wave H1b — the CONTRACTOR's worker-HR surface: a bottom-sheet listing the
// worker vacation requests scoped to THIS employer (`requestsForEmployer`,
// the H1a Provider.family keyed by employerId) and letting the contractor —
// the actual EMPLOYER, per [[manager-is-platform-admin-not-hr]] — אשר/דחה
// each pending one. PARALLEL to the manager dashboard's vacation block: the
// manager's surface is LEFT untouched; the contractor GAINS this one on the
// SAME shared `vacationRequestsProvider`.
//
// The decision REUSES the engine (`vacationRequestsProvider.notifier.approve/
// reject` — UNCHANGED) and REPLICATES the manager's `_decideVacation`
// side-effects: ONE 🔔 bell to the requester (`workerNotifsProvider`,
// per-username) + ONE chat line — but to 'th-worker-contractor' (the boss =
// the contractor) instead of the manager's 'th-worker-manager'. The engine's
// status-guard (`_decide` no-ops on an already-decided request) prevents a
// double-decide, so the bell/chat fire exactly once per request.
//
// Co-located with the T2 task-management on `tasks_screen`, the contractor's
// worker-management surface (no home_shell surgery). RTL, light tokens.

import 'package:buildsmart/state/board_auth.dart' show kDemoContractorId;
import 'package:buildsmart/state/required_docs_policy.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/vacation_requests.dart';
import 'package:buildsmart/state/worker_certs.dart';
import 'package:buildsmart/state/worker_notifs.dart';
import 'package:buildsmart/state/worker_trainings.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/reject_reason_dialog.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Open the contractor's worker-vacation HR sheet — the wire target for the
/// '👷 חופשות עובדים' action on `tasks_screen`.
Future<void> showContractorHrSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _ContractorHrSheet(),
  );
}

class _ContractorHrSheet extends ConsumerStatefulWidget {
  const _ContractorHrSheet();

  @override
  ConsumerState<_ContractorHrSheet> createState() => _ContractorHrSheetState();
}

class _ContractorHrSheetState extends ConsumerState<_ContractorHrSheet> {
  // Wave H3b — the add-a-required-document input (the WRITER section). One
  // controller for the section's TextField; disposed below. The other sections
  // are read-only/decide-only and need no local state.
  final _reqDocController = TextEditingController();

  @override
  void dispose() {
    _reqDocController.dispose();
    super.dispose();
  }

  /// cluster H1b — decide a worker vacation request. Mirrors the manager's
  /// `_decideVacation` (manager_dashboard_screen.dart): REUSE the engine
  /// (approve/reject — UNCHANGED, its status-guard prevents a double-decide),
  /// then fire ONE 🔔 bell on the requester's per-username feed and post ONE
  /// chat line — to 'th-worker-contractor' (the contractor is the approver,
  /// NOT the manager) — plus a contractor-side toast.
  void _decide(
    BuildContext context,
    WidgetRef ref,
    VacationRequest r, {
    required bool approve,
  }) {
    final notifier = ref.read(vacationRequestsProvider.notifier);
    if (approve) {
      notifier.approve(r.id);
    } else {
      notifier.reject(r.id);
    }
    // 🔔 the decision lands on the requester's bell (per-username — these are
    // worker requests, so it reaches exactly the worker who filed it). ONE
    // bell, matching the manager's single addNotification call.
    ref.read(workerNotifsProvider.notifier).addNotification(
          username: r.username,
          emoji: approve ? '✅' : '❌',
          title: approve ? 'בקשת החופשה אושרה' : 'בקשת החופשה נדחתה',
          body: r.range,
        );
    // The chat line goes to 'th-worker-contractor' (the worker's "קבלן"
    // thread) — the CONTRACTOR is the employer/approver here — sent as
    // BsRole.contractor, second-person, mirroring the manager's worker-thread
    // post but on the contractor's channel.
    ref.read(chatEngineProvider.notifier).send(
          'th-worker-contractor',
          BsRole.contractor,
          approve
              ? '✅ בקשת החופשה שלך (${r.range}) אושרה'
              : '❌ בקשת החופשה שלך (${r.range}) נדחתה',
        );
    showToast(
      context,
      approve
          ? '✅ אושרה חופשה: ${r.workerName} · ${r.range}'
          : '❌ נדחתה חופשה: ${r.workerName} · ${r.range}',
    );
  }

  /// Wave H2b — decide a worker TRAINING (the bidirectional approve-back).
  /// Mirrors [_decide]: REUSE the engine (`workerTrainingsProvider.notifier`
  /// approve/reject — its status-guard no-ops on an already-decided row), then
  /// fire ONE 🔔 bell on the requester's per-username feed and post ONE chat
  /// line to 'th-worker-contractor' — plus a contractor-side toast. Simpler
  /// than vacation: no reject-reason prompt, just approve/reject.
  void _decideTraining(
    BuildContext context,
    WidgetRef ref,
    WorkerTraining t, {
    required bool approve,
  }) {
    final notifier = ref.read(workerTrainingsProvider.notifier);
    if (approve) {
      notifier.approve(t.id);
    } else {
      notifier.reject(t.id);
    }
    ref.read(workerNotifsProvider.notifier).addNotification(
          username: t.username,
          emoji: approve ? '✅' : '❌',
          title: approve ? 'ההדרכה אושרה' : 'ההדרכה נדחתה',
          body: t.title,
        );
    ref.read(chatEngineProvider.notifier).send(
          'th-worker-contractor',
          BsRole.contractor,
          approve
              ? '✅ ההדרכה "${t.title}" אושרה'
              : '❌ ההדרכה "${t.title}" נדחתה',
        );
    showToast(
      context,
      approve
          ? '✅ אושרה הדרכה: ${t.username} · ${t.title}'
          : '❌ נדחתה הדרכה: ${t.username} · ${t.title}',
    );
  }

  @override
  Widget build(BuildContext context) {
    // The LIVE contractor queue — worker vacation requests scoped to THIS
    // employer (H1a's Provider.family: role=='worker' && employerId==arg,
    // newest-first). SERVER-SWAP: kDemoContractorId is the single-device demo
    // employer id; the real contractor uid when the backend lands.
    final requests = ref.watch(requestsForEmployer(kDemoContractorId));
    final pendingCount =
        requests.where((r) => r.status == kVacationPending).length;
    // Wave H2b — the two new sections' live data (same employer scope).
    final trainings = ref.watch(trainingsForEmployer(kDemoContractorId));
    final pendingTrainings = [
      for (final t in trainings)
        if (t.status == kTrainingPending) t,
    ];
    final certs = ref.watch(certsForEmployer(kDemoContractorId));
    // Wave H3b — the contractor's required-documents policy for THIS employer
    // (the WRITER section below). Empty by default → the honest empty-state.
    final required = ref.watch(requiredDocsForEmployer(kDemoContractorId));
    // Expiry aggregation for the SECTION-B banner (today's traffic-light).
    final now = DateTime.now();
    var expiredCount = 0;
    var expiringCount = 0;
    for (final c in certs) {
      switch (c.statusAt(now)) {
        case CertExpiryStatus.expired:
          expiredCount++;
        case CertExpiryStatus.expiringSoon:
          expiringCount++;
        case CertExpiryStatus.valid:
          break;
      }
    }

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
                    child: Text(
                      '👷 חופשות עובדים',
                      style: TextStyle(
                        color: BsTokens.inkLight,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    key: const ValueKey('contractor-hr-close'),
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
              Text(
                pendingCount > 0
                    ? 'בקשות חופשה של העובדים שלך — $pendingCount ממתינות להחלטה'
                    : 'בקשות חופשה של העובדים שלך',
                style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13),
              ),
              const SizedBox(height: BsTokens.space3),
              if (requests.isEmpty)
                // Honest empty state — no fake rows.
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: BsTokens.space5),
                  child: Text(
                    '🌴 אין בקשות חופשה מהעובדים שלך כרגע',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: BsTokens.inkLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                )
              else
                for (final r in requests) ...[
                  _VacationRow(
                    request: r,
                    onApprove: () =>
                        _decide(context, ref, r, approve: true),
                    onReject: () async {
                      // Optional rejection reason (the shared dialog): null =
                      // cancelled, no reject. The reason itself is surfaced in
                      // the toast/chat second-hand; the engine's reject is the
                      // single source of truth (status-guarded, no double).
                      final why = await promptRejectReason(context);
                      if (why == null || !context.mounted) return;
                      _decide(context, ref, r, approve: false);
                    },
                  ),
                  const SizedBox(height: BsTokens.space2),
                ],

              // ══ SECTION A — הדרכות עובדים (approve-back) ══
              const Divider(height: 32),
              const Text(
                '🎓 הדרכות עובדים',
                style: TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                pendingTrainings.isNotEmpty
                    ? 'הדרכות שהעובדים שלך רשמו — ${pendingTrainings.length} ממתינות לאישורך'
                    : 'הדרכות הבטיחות של העובדים שלך',
                style: const TextStyle(color: BsTokens.mutedLight, fontSize: 13),
              ),
              const SizedBox(height: BsTokens.space3),
              if (trainings.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: BsTokens.space5),
                  child: Text(
                    '🎓 אין הדרכות מהעובדים שלך כרגע',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: BsTokens.inkLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                )
              else
                for (final t in trainings) ...[
                  _TrainingRow(
                    training: t,
                    onApprove: () =>
                        _decideTraining(context, ref, t, approve: true),
                    onReject: () =>
                        _decideTraining(context, ref, t, approve: false),
                  ),
                  const SizedBox(height: BsTokens.space2),
                ],

              // ══ SECTION B — תעודות עובדים (read-only + expiry alerts) ══
              const Divider(height: 32),
              if (expiredCount > 0 || expiringCount > 0) ...[
                Container(
                  padding: const EdgeInsets.all(BsTokens.space3),
                  decoration: BoxDecoration(
                    color: BsTokens.warnText.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: BsTokens.warnText.withValues(alpha: 0.30),
                    ),
                  ),
                  child: Text(
                    [
                      if (expiredCount > 0) '⚠️ $expiredCount תעודות פגות תוקף',
                      if (expiringCount > 0) '$expiringCount לקראת חידוש',
                    ].join(' · '),
                    style: const TextStyle(
                      color: BsTokens.warnText,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                    ),
                  ),
                ),
                const SizedBox(height: BsTokens.space3),
              ],
              const Text(
                '📜 תעודות עובדים',
                style: TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'התעודות המקצועיות של העובדים שלך (לצפייה בלבד)',
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
              ),
              const SizedBox(height: BsTokens.space3),
              if (certs.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: BsTokens.space5),
                  child: Text(
                    '📜 אין תעודות מהעובדים שלך כרגע',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: BsTokens.inkLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                )
              else
                for (final c in certs) ...[
                  _CertRow(cert: c),
                  const SizedBox(height: BsTokens.space2),
                ],

              // ══ SECTION C — מסמכים נדרשים מהעובדים (WRITER/editor) ══
              // Unlike the read-only certs above, THIS section WRITES the
              // contractor's required-docs policy (#101) — the bidirectional
              // payoff: each name added here becomes a HARD gate on the worker
              // side (a worker can't start until they hold a VALID cert that
              // normalizes to this name). Same cert vocabulary, so it sits right
              // after the certs section.
              const Divider(height: 32),
              const Text(
                '📋 מסמכים נדרשים מהעובדים',
                style: TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'עובד לא יוכל להתחיל עבודה עד שתהיה לו תעודה בתוקף לכל פריט כאן '
                '(בנוסף לטופס 101).',
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
              ),
              const SizedBox(height: BsTokens.space3),
              if (required.isEmpty)
                // Honest empty-state — the TRUE default: no extra requirement
                // beyond the existing 101 + no-expired-cert rule. Do NOT
                // overstate what's enforced.
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: BsTokens.space2),
                  child: Text(
                    'לא הוגדרו מסמכים נדרשים. כרגע עובד נחסם רק על טופס-101 '
                    'לא-חתום או תעודה שפגה.',
                    style: TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
                  ),
                )
              else
                for (final (i, name) in required.indexed) ...[
                  Container(
                    padding: const EdgeInsets.all(BsTokens.space3),
                    decoration: BoxDecoration(
                      color: BsTokens.bgLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEDEDED)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '📋 $name',
                            style: const TextStyle(
                              color: BsTokens.inkLight,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        IconButton(
                          // Names may contain spaces → index-based key.
                          key: ValueKey('contractor-reqdoc-remove-$i'),
                          iconSize: 20,
                          constraints: const BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                          tooltip: 'הסר',
                          onPressed: () {
                            ref
                                .read(requiredDocsPolicyProvider.notifier)
                                .removeRequirement(kDemoContractorId, name);
                            showToast(context, '❌ הוסר מסמך נדרש: $name');
                          },
                          icon: const Icon(Icons.close,
                              color: BsTokens.mutedLight),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: BsTokens.space2),
                ],
              // Quick-fill SUGGESTIONS — real, well-known Israeli construction
              // worker cert names as one-tap fills. NOT fabricated data: the
              // contractor free-types anything via the field below; these are
              // only shortcuts that call addRequirement with the tapped name.
              Wrap(
                spacing: BsTokens.space2,
                runSpacing: BsTokens.space2,
                children: [
                  for (final s in _reqDocSuggestions)
                    InkWell(
                      key: ValueKey('contractor-reqdoc-suggest-$s'),
                      borderRadius:
                          BorderRadius.circular(BsTokens.radiusPill),
                      onTap: () {
                        ref
                            .read(requiredDocsPolicyProvider.notifier)
                            .addRequirement(kDemoContractorId, s);
                        showToast(context, '📋 נוסף מסמך נדרש: $s');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: BsTokens.inkLight.withValues(alpha: 0.06),
                          borderRadius:
                              BorderRadius.circular(BsTokens.radiusPill),
                          border: Border.all(color: const Color(0xFFEDEDED)),
                        ),
                        child: Text(
                          '➕ $s',
                          style: const TextStyle(
                            color: BsTokens.inkLight,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: BsTokens.space3),
              // ADD affordance — free-type a required cert/doc name + הוסף.
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const ValueKey('contractor-reqdoc-input'),
                      controller: _reqDocController,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addRequirement(context),
                      style: const TextStyle(
                        color: BsTokens.inkLight,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'שם מסמך/תעודה נדרשים…',
                        hintStyle: const TextStyle(
                          color: BsTokens.mutedLight,
                          fontSize: 13.5,
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: BsTokens.space3,
                          vertical: BsTokens.space3,
                        ),
                        filled: true,
                        fillColor: BsTokens.bgLight,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFEDEDED)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: BsTokens.inkLight,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: BsTokens.space2),
                  _DecideButton(
                    key: const ValueKey('contractor-reqdoc-add'),
                    label: '➕ הוסף',
                    color: const Color(0xFF1F8A4C),
                    onPressed: () => _addRequirement(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Wave H3b — commit the typed name as a required document, then clear the
  /// field. Guards empty input (the notifier already ignores empty, but we also
  /// skip the pointless toast). The notifier trims + dedupes by normalized name.
  void _addRequirement(BuildContext context) {
    final text = _reqDocController.text.trim();
    if (text.isEmpty) return;
    ref
        .read(requiredDocsPolicyProvider.notifier)
        .addRequirement(kDemoContractorId, text);
    _reqDocController.clear();
    showToast(context, '📋 נוסף מסמך נדרש: $text');
  }
}

/// Wave H3b — quick-fill SUGGESTIONS for the required-docs editor: real,
/// well-known Israeli construction worker certifications. These are one-tap
/// shortcuts only — the contractor free-types any name in the field; nothing
/// here is auto-applied or treated as the worker's actual held certs.
const List<String> _reqDocSuggestions = [
  'היתר עבודה בגובה',
  'תעודת מפעיל מלגזה',
  'הסמכת חשמלאי',
];

/// One worker vacation-request row — `🦺 name · range` + reason, and (while
/// pending) the ✅ אשר / ❌ דחה buttons; a decided row carries a read-only
/// status chip instead. Presentation only — decisions run through the
/// callbacks onto the shared engine.
class _VacationRow extends StatelessWidget {
  const _VacationRow({
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  final VacationRequest request;
  final VoidCallback onApprove;
  final Future<void> Function() onReject;

  @override
  Widget build(BuildContext context) {
    final pending = request.status == kVacationPending;
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
                  // These are worker requests (role=='worker' from the query),
                  // so the 🦺 worker icon is always correct here.
                  '🦺 ${request.workerName} · ${request.range}',
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              if (!pending) _StatusChip(status: request.status),
            ],
          ),
          if (request.reason.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              request.reason,
              style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
            ),
          ],
          if (pending) ...[
            const SizedBox(height: BsTokens.space3),
            Row(
              children: [
                Expanded(
                  child: _DecideButton(
                    key: ValueKey('contractor-vac-approve-${request.id}'),
                    label: '✅ אשר',
                    color: const Color(0xFF1F8A4C),
                    onPressed: onApprove,
                  ),
                ),
                const SizedBox(width: BsTokens.space2),
                Expanded(
                  child: _DecideButton(
                    key: ValueKey('contractor-vac-reject-${request.id}'),
                    label: '❌ דחה',
                    color: BsTokens.cardLight,
                    textColor: BsTokens.inkLight,
                    bordered: true,
                    // Fire-and-forget the async reject (reason prompt) — the
                    // Future is intentionally unawaited (tear-off).
                    onPressed: onReject,
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

/// Read-only decided-status pill — `אושרה` (green) / `נדחתה` (danger).
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final approved = status == kVacationApproved;
    final color = approved ? const Color(0xFF1F8A4C) : BsTokens.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      ),
      child: Text(
        approved ? 'אושרה' : 'נדחתה',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12.5,
        ),
      ),
    );
  }
}

/// One decision button (≥48dp tap target). Filled by default; `bordered` makes
/// it an outline variant for the secondary (דחה) action.
class _DecideButton extends StatelessWidget {
  const _DecideButton({
    required this.label,
    required this.color,
    required this.onPressed,
    this.textColor,
    this.bordered = false,
    super.key,
  });

  final String label;
  final Color color;
  final Color? textColor;
  final bool bordered;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      shape: bordered
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
              side: const BorderSide(color: Color(0xFFDDDDDD)),
            )
          : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        onTap: onPressed,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: textColor ?? Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

/// One worker training row (Wave H2b) — `🎓 username · title` + מדריך/date and
/// a status pill (ממתין/אושר/נדחה/נרשם); while pending it carries the
/// ✅ אשר / ❌ דחה buttons (the approve-back). Presentation only — decisions run
/// through the callbacks onto the shared `workerTrainingsProvider`.
class _TrainingRow extends StatelessWidget {
  const _TrainingRow({
    required this.training,
    required this.onApprove,
    required this.onReject,
  });

  final WorkerTraining training;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final pending = training.status == kTrainingPending;
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
                  '🎓 ${training.username} · ${training.title}',
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              _TrainingStatusChip(status: training.status),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${training.by} · ${_fmtDate(training.date)}',
            style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
          ),
          if (pending) ...[
            const SizedBox(height: BsTokens.space3),
            Row(
              children: [
                Expanded(
                  child: _DecideButton(
                    key: ValueKey('contractor-train-approve-${training.id}'),
                    label: '✅ אשר',
                    color: const Color(0xFF1F8A4C),
                    onPressed: onApprove,
                  ),
                ),
                const SizedBox(width: BsTokens.space2),
                Expanded(
                  child: _DecideButton(
                    key: ValueKey('contractor-train-reject-${training.id}'),
                    label: '❌ דחה',
                    color: BsTokens.cardLight,
                    textColor: BsTokens.inkLight,
                    bordered: true,
                    onPressed: onReject,
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

/// Read-only training-status pill — ממתין (amber) / אושר (green) / נדחה
/// (danger) / נרשם (muted), keyed off the training-status const.
class _TrainingStatusChip extends StatelessWidget {
  const _TrainingStatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      kTrainingApproved => ('אושר', const Color(0xFF1F8A4C)),
      kTrainingRejected => ('נדחה', BsTokens.danger),
      kTrainingPending => ('ממתין', BsTokens.warnText),
      _ => ('נרשם', BsTokens.mutedLight),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12.5,
        ),
      ),
    );
  }
}

/// One worker certificate row (Wave H2b) — `📜 username · name` + issuer/expiry
/// and an expiry traffic-light pill (🔴 פג / 🟡 פג בקרוב / 🟢 בתוקף), mirroring
/// `worker_safety_screen.dart`'s cert status. READ-ONLY — the contractor cannot
/// edit worker certs, so there are no action buttons.
class _CertRow extends StatelessWidget {
  const _CertRow({required this.cert});

  final WorkerCert cert;

  @override
  Widget build(BuildContext context) {
    // Same traffic-light mapping as worker_safety_screen's _CertRow.
    final (label, color) = switch (cert.statusAt(DateTime.now())) {
      CertExpiryStatus.expired => ('🔴 פג תוקף', BsTokens.danger),
      CertExpiryStatus.expiringSoon => ('🟡 פג בקרוב', BsTokens.warnText),
      CertExpiryStatus.valid => ('🟢 בתוקף', BsTokens.successDark),
    };
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
                  '📜 ${cert.username} · ${cert.name}',
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            cert.issuer.isNotEmpty
                ? '${cert.issuer} · בתוקף עד ${_fmtDate(cert.expiry)}'
                : 'בתוקף עד ${_fmtDate(cert.expiry)}',
            style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

/// Short date label (date-only semantics) — `dd.MM.yyyy`, shared by the
/// training + cert rows.
String _fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.'
    '${d.month.toString().padLeft(2, '0')}.${d.year}';
