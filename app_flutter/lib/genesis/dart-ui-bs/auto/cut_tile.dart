// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: features__fittings__intel__build_plan_screen:_CutTile (בנייה-חכמה main) · צרור-1 · מודל-שוטח: 4 שדות · props-שורש: label, label2, cutLength, fromFamily, od, toFamily
// התוכן: new/dart-data-bs/auto/features__fittings__intel__build_plan_screen_content.dart
import 'package:flutter/material.dart';

class CutTile extends StatelessWidget {
  CutTile({required this.label, required this.label2, required this.cutLength, required this.fromFamily, required this.od, required this.toFamily, });
  final String label;
  final String label2;
  final double cutLength;
  final String fromFamily;
  final int od;
  final String toFamily;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF23303D),
              borderRadius: BorderRadius.circular(8)),
            child: Text('${cutLength.toStringAsFixed(1)}${label}',
                style: const TextStyle(
                    fontFamily: 'Heebo',
                    color: Color(0xFF7FC08A),
                    fontWeight: FontWeight.w700,),),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${fromFamily}${label2}${od} → ${toFamily}',
              style: const TextStyle(
                  fontFamily: 'Heebo', color: Colors.white, fontSize: 13,),
            ),
          ),
        ],
      ),
    );
  }
}
