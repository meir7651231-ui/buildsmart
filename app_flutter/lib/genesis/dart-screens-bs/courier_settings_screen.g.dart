// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__courier_settings_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/courier_info_section.dart';
import '../dart-data-bs/auto/screens__courier_settings_screen_content.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class CourierSettingsScreenTokens {
  const CourierSettingsScreenTokens();

}

class CourierSettingsScreenComposed extends StatelessWidget {
  const CourierSettingsScreenComposed({required this.onTap,VoidCallback, required this.onTap2,VoidCallback, required this.t, super.key});

  final VoidCallback onTap;
  final VoidCallback onTap2;

  final CourierSettingsScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          CourierInfoSection(
            title: courier_info_section_title,
            title2: courier_info_section_title2,
            body: courier_info_section_body,
            fallback: courier_info_section_fallback,
            title3: courier_info_section_title3,
            body2: courier_info_section_body2,
            fallback2: courier_info_section_fallback2,
            onTap: onTap,
            onTap2: onTap2,
          ),
        ],
      );
}
