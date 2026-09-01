// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__manager_dashboard_screen:_PipelineRow (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class PipelineRow extends StatelessWidget {
  const PipelineRow({
    required this.label,
    required this.count,
    required this.max,
    required this.color,
    this.onTap,
  });

  final String label;
  final int count;
  final int max;
  final Color color;

  /// Drill-down: tapping a stage row opens the הזמנות tab. Null → non-interactive.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fraction = max <= 0 ? 0.0 : (count / max).clamp(0.0, 1.0);
    final row = Padding(
      padding: const EdgeInsets.only(bottom: BsTokens.space3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: BsTokens.inkLight,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '$count',
                  style: const TextStyle(
                    color: BsTokens.inkLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 7,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
    );
    return Semantics(
      label: '$label: $count',
      button: onTap != null,
      child: onTap == null
          ? row
          : Material(
              type: MaterialType.transparency,
              child: InkWell(onTap: onTap, child: row),
            ),
    );
  }
}
