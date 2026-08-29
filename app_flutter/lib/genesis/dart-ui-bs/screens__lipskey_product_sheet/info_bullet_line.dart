// 🧼 אטום · InfoBulletLine — שורת-תבליט: קידומת • + טקסט מיושר-ימין.
// מוצא: screens__lipskey_product_sheet.dart:2811-2817 (_infoBullet).
// התוכן (polyrollInfo/huliotInfo/hygieneInfo/weldPlanSteps ב-content) מוזרק מהקופסה.
import 'package:flutter/material.dart';

class InfoBulletLine extends StatelessWidget {
  const InfoBulletLine({required this.text, required this.color, super.key});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        child: Text('• $text',
            textAlign: TextAlign.right,
            style: TextStyle(color: color, fontSize: 11.5, height: 1.35)),
      );
}
