// 🧼 אטום · ScoreBandChip — צ'יפ-ציון קטן: טקסט על רקע-רצועת-ציון עם מסגרת.
// מוצא: screens__lipskey_product_sheet.dart:881-896 (chip המקומי בכותרת-המוצר —
// שלמות-נתונים t_f84ce1e0 / מוכנות-התקנה t_3a3361c4). הטקסט המפורמט והצבעים
// (scoreBandColors = מנוע-מחצבה) מוזרמים מהקופסה.
import 'package:flutter/material.dart';

class ScoreBandChip extends StatelessWidget {
  const ScoreBandChip({
    required this.text,
    required this.bgColor,
    required this.borderColor,
    required this.fgColor,
    super.key,
  });
  final String text;
  final Color bgColor, borderColor, fgColor;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Text(text,
            style: TextStyle(
                color: fgColor, fontSize: 11, fontWeight: FontWeight.w700)),
      );
}
