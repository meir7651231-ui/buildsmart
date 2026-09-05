// 🧼 חוט-תצוגה · OrderCard — כרטיס-הזמנה. התוויות מגיעות מפורמטות (הקופסה
// מרכיבה 'N פריטים' / '₪X' דרך אטומי-הפורמט) — כאן אפס טקסט, אפס ידע-דומיין.
import 'package:flutter/material.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    required this.stageLabel, required this.itemsLabel, required this.sumLabel,
    required this.onTap, required this.cardColor, required this.inkColor,
    required this.mutedColor, required this.borderColor, required this.radius,
    required this.width, super.key,
  });
  final String stageLabel, itemsLabel, sumLabel;
  final VoidCallback onTap;
  final Color cardColor, inkColor, mutedColor, borderColor;
  final double radius, width;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: Container(
          width: width,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(stageLabel, style: TextStyle(color: inkColor, fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 4),
            Text(itemsLabel, style: TextStyle(color: mutedColor, fontSize: 11)),
            Text(sumLabel, style: TextStyle(color: inkColor, fontWeight: FontWeight.w800, fontSize: 14)),
          ]),
        ),
      );
}
