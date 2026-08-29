// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__contractor_hr_sheet:_VacationRow (בנייה-חכמה main) · צרור-3 · מודל-שוטח: 5 שדות · props-שורש: label, label2, status, workerName, range, reason, id, label3, label4
// התוכן: new/dart-data-bs/auto/screens__contractor_hr_sheet_content.dart
import 'package:flutter/material.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/state/vacation_requests.dart';

class VacationRow extends StatelessWidget {
  VacationRow({required this.label, required this.label2, required this.status, required this.workerName, required this.range, required this.reason, required this.id, required this.label3, required this.label4, 
    
    required this.onApprove,
    required this.onReject,});
  final String label;
  final String label2;
  final String status;
  final String workerName;
  final String range;
  final String reason;
  final String id;
  final String label3;
  final String label4;
  final VoidCallback onApprove;
  final Future<void> Function() onReject;

  @override
  Widget build(BuildContext context) {
    late final pending = status == kVacationPending;
    return Container(
      padding: const EdgeInsets.all(BsTokens.space3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDEDED))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  // These are worker requests (role=='worker' from the query),
                  // so the 🦺 worker icon is always correct here.
                  '🦺 ${workerName} · ${range}',
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              if (!pending) _StatusChip(status: status, label3: label3, label4: label4),
            ],
          ),
          if (reason.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              reason,
              style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
            ),
          ],
          if (pending) ...[
            const SizedBox(height: BsTokens.space3),
            Row(
              children: [
                Expanded(
                  child: _DecideButton(
                    key: ValueKey('contractor-vac-approve-${id}'),
                    label: label,
                    color: const Color(0xFF1F8A4C),
                    onPressed: onApprove,
                  ),
                ),
                const SizedBox(width: BsTokens.space2),
                Expanded(
                  child: _DecideButton(
                    key: ValueKey('contractor-vac-reject-${id}'),
                    label: label2,
                    color: Theme.of(context).colorScheme.surface,
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

class _StatusChip extends StatelessWidget {
  _StatusChip({required this.label3, required this.label4, required this.status});
  final String label3;
  final String label4;
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
        approved ? label3 : label4,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12.5,
        ),
      ),
    );
  }
}

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
