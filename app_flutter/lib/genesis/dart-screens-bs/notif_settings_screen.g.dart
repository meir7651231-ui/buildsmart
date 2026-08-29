// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__notif_settings_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/quick_actions_section.dart';
import '../dart-data-bs/auto/screens__notif_settings_screen_content.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class NotifSettingsScreenTokens {
  const NotifSettingsScreenTokens();

}

class NotifSettingsScreenComposed extends StatelessWidget {
  const NotifSettingsScreenComposed({required this.onTap, required this.t, super.key});

  final VoidCallback onTap;

  final NotifSettingsScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          QuickActionsSection(
            title: quick_actions_section_title,
            label: quick_actions_section_label,
            label2: quick_actions_section_label2,
            label3: quick_actions_section_label3,
            label4: quick_actions_section_label4,
            fallback: quick_actions_section_fallback,
            fallback2: quick_actions_section_fallback2,
            onTap: onTap,
          ),
        ],
      );
}
