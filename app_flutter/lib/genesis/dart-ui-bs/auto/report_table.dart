// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__finance_hub_sheets:_ReportTable (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';

class ReportTable extends StatelessWidget {
  const ReportTable({required this.rows});
  final List<(String, String, bool)> rows; // (label, value, big)
  @override
  Widget build(BuildContext context) {
    const border = BorderSide(color: Color(0xFFDDDDDD));
    return Table(
      border: const TableBorder(
        top: border,
        bottom: border,
        left: border,
        right: border,
        horizontalInside: border,
        verticalInside: border,
      ),
      columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth()},
      children: [
        for (final r in rows)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  r.$1,
                  style: const TextStyle(
                    color: Color(0xFF16191D),
                    fontSize: 13,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  r.$2,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: const Color(0xFF16191D),
                    fontSize: r.$3 ? 16 : 13,
                    fontWeight: r.$3 ? FontWeight.w800 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
