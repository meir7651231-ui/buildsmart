// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__lipskey_product_sheet:_EmptyHint (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';

class EmptyHint extends StatelessWidget {
  const EmptyHint(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 6),
        child: Text(text,
            textAlign: TextAlign.right,
            style: const TextStyle(
                color: Color(0xFF9AA3B2),
                fontSize: 11,
                fontStyle: FontStyle.italic)),
      );
}
