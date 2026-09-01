// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__courier_attendance_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/courier_attendance_send_report_button.dart';
import '../dart-ui-bs/auto/courier_attendance_table_row.dart';
import '../dart-ui-bs/auto/today_stat.dart';
import '../dart-data-bs/auto/screens__courier_attendance_screen_content.dart';
import '../dart-data-bs/auto/screens__courier_attendance_screen_content2.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class CourierAttendanceScreenTokens {
  const CourierAttendanceScreenTokens();

}

class CourierAttendanceScreenComposed extends StatelessWidget {
  const CourierAttendanceScreenComposed({required this.onPressed, required this.enabled, required this.header, required this.label, required this.value, required this.t, super.key});

  final VoidCallback onPressed;
  final bool enabled;
  final bool header;
  final String label;
  final String value;
  final CourierAttendanceScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          CourierAttendanceSendReportButton(
            title: courier_attendance_send_report_button_title,
            body: courier_attendance_send_report_button_body,
            enabled: enabled,
            label: label,
            onPressed: onPressed,
          ),
          TodayStat(
            label: today_stat_label,
            value: value,
          ),
          CourierAttendanceTableRow(
            date: courier_attendance_table_row_date,
            inText: courier_attendance_table_row_in_text,
            outText: courier_attendance_table_row_out_text,
            totalText: courier_attendance_table_row_total_text,
            header: header,
          ),
        ],
      );
}
