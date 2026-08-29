// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__courier_attendance_screen:_TableRow (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class CourierAttendanceTableRow extends StatelessWidget {
  const CourierAttendanceTableRow({
    required this.date,
    required this.inText,
    required this.outText,
    required this.totalText,
    this.header = false,
  });

  final String date;
  final String inText;
  final String outText;
  final String totalText;
  final bool header;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: header ? BsTokens.mutedLight : BsTokens.inkLight,
      fontSize: header ? 12 : 13.5,
      fontWeight: header ? FontWeight.w700 : FontWeight.w600,
    );
    Widget cell(String t, int flex) =>
        Expanded(flex: flex, child: Text(t, style: style));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          cell(date, 3),
          cell(inText, 2),
          cell(outText, 2),
          cell(totalText, 3),
        ],
      ),
    );
  }
}
