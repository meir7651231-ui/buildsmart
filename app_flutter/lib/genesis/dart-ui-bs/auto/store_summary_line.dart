// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__store_screen:_SummaryLine (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class StoreSummaryLine extends StatelessWidget {
  const StoreSummaryLine({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style =
        bold
            ? const TextStyle(
              color: BsTokens.inkLight,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            )
            : const TextStyle(color: Color(0xFF888888), fontSize: 13);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: style), Text(value, style: style)],
    );
  }
}
