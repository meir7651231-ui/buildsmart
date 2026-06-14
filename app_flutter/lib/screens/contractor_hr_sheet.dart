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
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/vacation_requests.dart';
import 'package:buildsmart/state/worker_notifs.dart';
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

class _ContractorHrSheet extends ConsumerWidget {
  const _ContractorHrSheet();

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The LIVE contractor queue — worker vacation requests scoped to THIS
    // employer (H1a's Provider.family: role=='worker' && employerId==arg,
    // newest-first). SERVER-SWAP: kDemoContractorId is the single-device demo
    // employer id; the real contractor uid when the backend lands.
    final requests = ref.watch(requestsForEmployer(kDemoContractorId));
    final pendingCount =
        requests.where((r) => r.status == kVacationPending).length;

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
            ],
          ),
        ),
      ),
    );
  }
}

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
                    onPressed: () {
                      // Fire-and-forget the async reject (reason prompt).
                      onReject();
                    },
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
