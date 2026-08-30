// 🧼 אטום · InfoHeadLine — כותרת-משנה בגוון-הרצועה, מיושרת-ימין.
// מוצא: screens__lipskey_product_sheet.dart:2819-2825 (_infoHead).
// הכותרות (t_aea296db חומר גלם · t_32bf4be3 יתרונות · t_ba3d5a63 תקינות · t_7f5b391c
// לפי נתוני היבוא ועוד — ב-content) מוזרקות מהקופסה.
import 'package:flutter/material.dart';

class InfoHeadLine extends StatelessWidget {
  const InfoHeadLine({required this.text, required this.tint, super.key});
  final String text;
  final Color tint;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 2),
        child: Text(text,
            textAlign: TextAlign.right,
            style: TextStyle(
                color: tint, fontSize: 12, fontWeight: FontWeight.w800)),
      );
}
