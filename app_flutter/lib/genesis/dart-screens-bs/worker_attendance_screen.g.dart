// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__worker_attendance_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/location_button.dart';
import '../dart-ui-bs/auto/send_report_button.dart';
import '../dart-ui-bs/auto/today_stat.dart';
import '../dart-data-bs/auto/screens__worker_attendance_screen_content.dart';
import '../dart-data-bs/auto/screens__worker_attendance_screen_content2.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class WorkerAttendanceScreenTokens {
  const WorkerAttendanceScreenTokens();

}

class WorkerAttendanceScreenComposed extends StatelessWidget {
  const WorkerAttendanceScreenComposed({required this.onPressed, required this.onTap, required this.enabled, required this.label, required this.query, required this.value, required this.t, super.key});

  final VoidCallback onPressed;
  final VoidCallback onTap;
  final bool enabled;
  final String label;
  final String query;
  final String value;
  final WorkerAttendanceScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          SendReportButton(
            enabled: enabled,
            label: label,
            onPressed: onPressed,
          ),
          TodayStat(
            label: today_stat_label,
            value: value,
          ),
          LocationButton(
            label2: location_button_label2,
            fallback: location_button_fallback,
            onTap: onTap,
            label: label,
            query: query,
          ),
        ],
      );
}
