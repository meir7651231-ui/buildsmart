// 🧼 אטום · StageChip — תג-שלב-הזמנה: רקע/מסגרת נגזרים מ-color באלפא (0.15/0.4).
// מוצא: screens__store_screen.dart:4022-4042 (שורת-הזמנה, 8/2·r10·fs11) וגם
// 4115-4135 (sheet-הזמנה, 10/4·r20·fs12) — אותו מנגנון, מידות מוזרקות.
// stageLabel + stageColor מגיעים מהקופסה (orderStages ב-content).
import 'package:flutter/material.dart';

class StageChip extends StatelessWidget {
  const StageChip({
    required this.label, required this.color,
    required this.hPad, required this.vPad,
    required this.radius, required this.fontSize, super.key,
  });
  final String label;
  final Color color;
  final double hPad, vPad, radius, fontSize;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.w600),
        ),
      );
}
