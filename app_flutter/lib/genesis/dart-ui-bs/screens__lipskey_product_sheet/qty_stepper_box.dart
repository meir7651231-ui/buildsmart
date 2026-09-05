// 🧼 אטום · QtyStepperBox — סטפר-כמות בקופסה-ממוסגרת: כפתורי-גליף − / + סביב המונה.
// מוצא: screens__lipskey_product_sheet.dart:1317-1358 (_QtyStepper).
// ≠ SmartQtyStepper של מסך-החנות (אייקונים+Tooltip+רקע-אלפא, בלי מסגרת) — מנגנון אחר.
// clamp-המינימום (max(1, v)) נשאר בקופסה (במקור: onChanged של ההורה, שורה 1197).
import 'package:flutter/material.dart';

class QtyStepperBox extends StatelessWidget {
  const QtyStepperBox({
    required this.qty,
    required this.onChanged,
    required this.inkColor,
    required this.borderColor,
    required this.surfaceColor,
    super.key,
  });
  final int qty;
  final ValueChanged<int> onChanged;
  final Color inkColor, borderColor, surfaceColor;

  @override
  Widget build(BuildContext context) {
    Widget b(String s, VoidCallback t) => InkWell(
          onTap: t,
          child: SizedBox(
              width: 38,
              height: 44,
              child: Center(
                  child: Text(s,
                      style: TextStyle(color: inkColor, fontSize: 20)))),
        );
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          b('−', () => onChanged(qty - 1)),
          SizedBox(
              width: 34,
              child: Center(
                  child: Text('$qty',
                      style: TextStyle(
                          color: inkColor,
                          fontSize: 17,
                          fontWeight: FontWeight.w800)))),
          b('+', () => onChanged(qty + 1)),
        ],
      ),
    );
  }
}
