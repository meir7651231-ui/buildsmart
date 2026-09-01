// 🧼 אטום · EmptyHintText — שורת-רמז-ריקנות נטויה מיושרת-ימין.
// מוצא: screens__lipskey_product_sheet.dart:3109-3122 (_EmptyHint).
// הטקסטים (stripEmptyHints ב-content: t_3cca7958 · t_c5cdf8bb · t_334a1128 ועוד) מוזרקים.
import 'package:flutter/material.dart';

class EmptyHintText extends StatelessWidget {
  const EmptyHintText({required this.text, required this.color, super.key});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 6),
        child: Text(text,
            textAlign: TextAlign.right,
            style: TextStyle(
                color: color, fontSize: 11, fontStyle: FontStyle.italic)),
      );
}
