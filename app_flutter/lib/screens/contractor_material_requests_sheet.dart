// Wave E3b · 📥 בקשות חומר — the CONTRACTOR's inbox for the structured material
// requests filed by their workers (the worker side is E3a's
// `worker_employer_stock_sheet.dart` → `MaterialRequestsNotifier.submit`). This
// sheet reads `requestsForEmployer(kDemoContractorId)` — every request addressed
// to this contractor, newest-first — and lets the contractor advance each one's
// status (requested → ordered → supplied / declined) via `setStatus`. The worker
// watches the same request flip live (bidirectional, the `vacation_requests`
// shared-queue pattern). Worker NEVER mutates stock; this is a request inbox, not
// a stock edit.
//
// Style mirrors `worker_notifs_sheet.dart`: white card sheet, RTL, grabber,
// header + X close, honest empty state, ≥48dp tap targets.
//
// SERVER-SWAP: `kDemoContractorId` is the one-device demo contractor's employer
// id (board_auth.dart). When the backend lands it becomes the real contractor
// uid carried on the auth claim — ONLY the id source swaps; this sheet and the
// `requestsForEmployer` filter stay as-is.

import 'package:buildsmart/state/board_auth.dart' show kDemoContractorId;
import 'package:buildsmart/state/material_requests_engine.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens the contractor's material-requests inbox (list + advance-status).
Future<void> showContractorMaterialRequestsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ContractorMaterialRequestsSheet(),
  );
}

/// The four lifecycle statuses, surfaced as a chip — label + colors. A single
/// source so the chip and the per-status action set never drift.
({String label, Color fg, Color bg}) _statusChip(String status) {
  switch (status) {
    case kMatReqOrdered:
      return (label: 'הוזמן', fg: BsTokens.warnText, bg: const Color(0xFFFFF4E0));
    case kMatReqSupplied:
      return (
        label: 'סופק',
        fg: BsTokens.successDark,
        bg: const Color(0xFFE8F8EE)
      );
    case kMatReqDeclined:
      return (
        label: 'נדחה',
        fg: BsTokens.dangerDark,
        bg: const Color(0xFFFDECEC)
      );
    case kMatReqRequested:
    default:
      return (
        label: 'ממתין',
        fg: BsTokens.brandDark,
        bg: const Color(0x14FF7A18) // brand @ 8%
      );
  }
}

class _ContractorMaterialRequestsSheet extends ConsumerWidget {
  const _ContractorMaterialRequestsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The contractor's own inbox: every request addressed to this device's one
    // contractor (kDemoContractorId), newest-first off the live engine.
    final requests = ref.watch(requestsForEmployer(kDemoContractorId));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scroll) => Container(
          decoration: const BoxDecoration(
            color: BsTokens.cardLight,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(BsTokens.radiusCard),
            ),
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
              // ── header: title + X close ──
              Row(
                children: [
                  const Expanded(
                    child: CfgText(
                      'contractor_material_requests_sheet.t01',
                      '📥 בקשות חומר',
                      style: TextStyle(
                        color: BsTokens.inkLight,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'סגירה',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: BsTokens.mutedLight),
                  ),
                ],
              ),
              const SizedBox(height: BsTokens.space2),

              if (requests.isEmpty)
                // Honest empty state — the inbox fills only from real worker
                // submissions (worker_employer_stock_sheet → submit), never seeded.
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: BsTokens.space5),
                  child: CfgText(
                    'contractor_material_requests_sheet.t02',
                    'אין בקשות חומר עדיין.\n'
                    'כשעובד ישלח בקשת חומרים — היא תופיע כאן ותוכל לעדכן את הסטטוס.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: BsTokens.mutedLight, fontSize: 13.5),
                  ),
                )
              else
                for (final r in requests)
                  _RequestCard(
                    request: r,
                    onSetStatus: (status) => ref
                        .read(materialRequestsProvider.notifier)
                        .setStatus(r.id, status),
                  ),
              const SizedBox(height: BsTokens.space4),
            ],
          ),
        ),
      ),
    );
  }
}

/// One request card — worker name + a status chip, the requested items, an
/// optional note, then the status-advance actions. A terminal request
/// (supplied/declined) shows no actions (the engine guards re-opening anyway).
class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request, required this.onSetStatus});

  final MaterialRequest request;
  final ValueChanged<String> onSetStatus;

  bool get _isTerminal =>
      request.status == kMatReqSupplied || request.status == kMatReqDeclined;

  @override
  Widget build(BuildContext context) {
    final chip = _statusChip(request.status);
    final who = request.workerName.trim().isEmpty ? 'עובד' : request.workerName;

    return Container(
      margin: const EdgeInsets.only(bottom: BsTokens.space2),
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: BsTokens.bgLight,
        borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── who + status chip ──
          Row(
            children: [
              const Text('👷', style: TextStyle(fontSize: 18)),
              const SizedBox(width: BsTokens.space2),
              Expanded(
                child: Text(
                  who,
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: chip.bg,
                  borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                ),
                child: Text(
                  chip.label,
                  style: TextStyle(
                    color: chip.fg,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: BsTokens.space2),
          // ── requested items (one per line) ──
          if (request.items.isEmpty)
            const CfgText(
              'contractor_material_requests_sheet.t03',
              'ללא פריטים',
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
            )
          else
            for (final item in request.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '• $item',
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontSize: 13.5,
                    height: 1.3,
                  ),
                ),
              ),
          // ── optional note ──
          if (request.note.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '📝 ${request.note}',
              style: const TextStyle(
                color: BsTokens.mutedLight,
                fontSize: 12.5,
                fontStyle: FontStyle.italic,
                height: 1.3,
              ),
            ),
          ],
          // ── actions: advance the status (hidden once terminal) ──
          if (!_isTerminal) ...[
            const SizedBox(height: BsTokens.space2),
            Wrap(
              spacing: BsTokens.space2,
              runSpacing: BsTokens.space1,
              children: [
                // 'ordered' only offered while still 'requested' (once ordered,
                // the next honest steps are supplied/declined).
                if (request.status == kMatReqRequested)
                  _ActionButton(
                    label: 'סמן הוזמן',
                    color: BsTokens.brandDark,
                    onTap: () => onSetStatus(kMatReqOrdered),
                  ),
                _ActionButton(
                  label: 'סופק',
                  color: BsTokens.successDark,
                  onTap: () => onSetStatus(kMatReqSupplied),
                ),
                _ActionButton(
                  label: 'דחה',
                  color: BsTokens.dangerDark,
                  onTap: () => onSetStatus(kMatReqDeclined),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// A status-advance action — an OutlinedButton sized to keep the ≥48dp target.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
      ),
    );
  }
}
