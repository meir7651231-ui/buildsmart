// 🧼 אטום · SpecRow — שורת-מפרט: גליף + תווית + ערך מיושר-לסוף (עוטף ערכים ארוכים).
// מוצא: screens__lipskey_product_sheet.dart:2038-2061 (_SpecRow — פונקציית-widget במקור,
// כאן מחלקה). מפתחות/ערכים (t_be49d01c צבע · t_57c67db4 · t_1c17f824 · t_5cdc3761 וכו')
// מוזרמים מ-content/dims דרך הקופסה.
import 'package:flutter/material.dart';

class SpecRow extends StatelessWidget {
  const SpecRow({
    required this.emoji,
    required this.label,
    required this.value,
    required this.labelColor,
    required this.valueColor,
    super.key,
  });
  final String emoji, label, value;
  final Color labelColor, valueColor;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 15)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(label,
                  style: TextStyle(color: labelColor, fontSize: 13)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(value,
                  textAlign: TextAlign.end,
                  style: TextStyle(color: valueColor, fontSize: 13)),
            ),
          ],
        ),
      );
}
