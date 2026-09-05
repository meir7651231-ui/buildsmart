// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__worker_settings_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/info_section.dart';
import '../dart-ui-bs/auto/notif_row.dart';
import '../dart-data-bs/auto/screens__worker_settings_screen_content.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class WorkerSettingsScreenTokens {
  const WorkerSettingsScreenTokens();

}

class WorkerSettingsScreenComposed extends StatelessWidget {
  const WorkerSettingsScreenComposed({required this.onTap, required this.onTap2, required this.fallback, required this.fallback2, required this.title, required this.t, super.key});

  final VoidCallback onTap;
  final VoidCallback onTap2;
  final String fallback;
  final String fallback2;
  final String title;
  final WorkerSettingsScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          NotifRow(
            fallback: notif_row_fallback,
            onTap: onTap,
          ),
          InfoSection(
            title: title,
            fallback: fallback,
            fallback2: fallback2,
            onTap: onTap,
            onTap2: onTap2,
          ),
        ],
      );
}
