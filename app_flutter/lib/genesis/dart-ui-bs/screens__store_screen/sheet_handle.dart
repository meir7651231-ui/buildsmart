// 🧼 אטום · SheetHandle — ידית-גרירה של bottom-sheet (36×4 מעוגל, ממורכז).
// מוצא: התבנית החוזרת ב-screens__store_screen.dart:1059 / 2909 / 3325 / 4092.
// sheet_scaffold מטמיע אותה בעצמו (חוק-1); האטום הזה משרת קופסאות שבונות sheet חופשי
// (_CheckoutSheet / רשימות-שמורות / _OrderSheet).
import 'package:flutter/material.dart';

class SheetHandle extends StatelessWidget {
  const SheetHandle({required this.color, super.key});
  final Color color;

  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
}
