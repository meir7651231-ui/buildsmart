// 🧼 אטום · SpecMonoRow — שורת-מפרט-הנדסי: תווית: + ערך מונוספייס מיושר-שמאל.
// מוצא: screens__lipskey_product_sheet.dart:2769-2790 (row המקומי של _buildSpec).
// המפתחות (specPanelKeys ב-content: t_9a215501 חומר · t_a0fdf3a3 · t_f71c2fc7 ועוד)
// והערכים המפורמטים מוזרמים מהקופסה (engineeringSpecFor = מנוע-מחצבה).
import 'package:flutter/material.dart';

class SpecMonoRow extends StatelessWidget {
  const SpecMonoRow({
    required this.label,
    required this.value,
    required this.labelColor,
    required this.valueColor,
    super.key,
  });
  final String label, value;
  final Color labelColor, valueColor;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
        child: Row(
          children: [
            Text('$label:',
                style: TextStyle(
                    color: labelColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(value,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: valueColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace')),
            ),
          ],
        ),
      );
}
