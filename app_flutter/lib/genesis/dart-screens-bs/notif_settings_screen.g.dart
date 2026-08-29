// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__notif_settings_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/notif_settings_switch_row.dart';
import '../dart-ui-bs/auto/quick_actions_section.dart';
import '../dart-ui-bs/auto/snooze_sheet.dart';
import '../dart-data-bs/auto/screens__notif_settings_screen_content.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class NotifSettingsScreenTokens {
  const NotifSettingsScreenTokens();

}

class NotifSettingsScreenComposed extends StatelessWidget {
  const NotifSettingsScreenComposed({required this.onChanged, required this.onTap, required this.onTap2, required this.onTap3, required this.onTap4, required this.label, required this.requiresServer, required this.underConstruction, required this.value, required this.t, super.key});

  final VoidCallback onChanged;
  final VoidCallback onTap;
  final VoidCallback onTap2;
  final VoidCallback onTap3;
  final VoidCallback onTap4;
  final String label;
  final bool requiresServer;
  final bool underConstruction;
  final bool value;
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
            fallback3: quick_actions_section_fallback3,
            fallback4: quick_actions_section_fallback4,
            onTap: onTap,
            onTap2: onTap2,
            fallback5: quick_actions_section_fallback5,
            onTap3: onTap3,
            fallback6: quick_actions_section_fallback6,
            fallback7: quick_actions_section_fallback7,
            onTap4: onTap4,
          ),
          SnoozeSheet(
            label: snooze_sheet_label,
            label2: snooze_sheet_label2,
            label3: snooze_sheet_label3,
            label4: snooze_sheet_label4,
            fallback: snooze_sheet_fallback,
            onTap: onTap,
          ),
          NotifSettingsSwitchRow(
            fallback: notif_settings_switch_row_fallback,
            fallback2: notif_settings_switch_row_fallback2,
            label: label,
            value: value,
            onChanged: onChanged,
            requiresServer: requiresServer,
            underConstruction: underConstruction,
          ),
        ],
      );
}
