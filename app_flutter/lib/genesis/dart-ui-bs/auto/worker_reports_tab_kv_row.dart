// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__worker_reports_tab:_KvRow (בנייה-חכמה main) · צרור-1 · props-שורש: label2
// התוכן: new/dart-data-bs/auto/screens__worker_reports_tab_content.dart
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class WorkerReportsTabKvRow extends StatelessWidget {
  WorkerReportsTabKvRow({required this.label2, required this.label, required this.value, this.onTap});
  final String label2;

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: BsTokens.inkLight, fontSize: 13.5),
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
        if (onTap != null) ...[
          const SizedBox(width: 2),
          const Icon(Icons.chevron_left, size: 18, color: BsTokens.mutedLight),
        ],
      ],
    );

    if (onTap == null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: BsTokens.space2),
        child: row,
      );
    }
    return Semantics(
      button: true,
      label: '$label, $value${label2}',
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48), // ≥48dp target
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ExcludeSemantics(child: row),
          ),
        ),
      ),
    );
  }
}
