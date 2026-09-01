// 🧼 אטום · SummaryLine — שורת-תווית/ערך של סיכום (רגילה או מודגשת).
// מוצא: screens__store_screen.dart:2620 (_SummaryLine). משמש גם את שורות-הסיכום של
// _CheckoutSheet/_OrderSheet בחיווט-קופסה. קיים גם עותק-מוטמע ב-cart_summary_card
// (חוק-1: אטום לא מייבא אטום) — מתועד ב-wiring_notes.
import 'package:flutter/material.dart';

class SummaryLine extends StatelessWidget {
  const SummaryLine({
    required this.label, required this.value,
    required this.inkColor, required this.mutedColor,
    this.bold = false, super.key,
  });
  final String label, value;
  final Color inkColor, mutedColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? TextStyle(color: inkColor, fontSize: 15, fontWeight: FontWeight.w800)
        : TextStyle(color: mutedColor, fontSize: 13);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: style), Text(value, style: style)],
    );
  }
}
