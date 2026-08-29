// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__catalog_settings_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/ai_section.dart';
import '../dart-ui-bs/auto/info_section.dart';
import '../dart-ui-bs/auto/profile_row.dart';
import '../dart-data-bs/auto/screens__catalog_settings_screen_content.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class CatalogSettingsScreenTokens {
  const CatalogSettingsScreenTokens();

}

class CatalogSettingsScreenComposed extends StatelessWidget {
  const CatalogSettingsScreenComposed({required this.onTap,VoidCallback, required this.onTap2,VoidCallback, required this.t, super.key});

  final VoidCallback onTap;
  final VoidCallback onTap2;

  final CatalogSettingsScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          ProfileRow(
            fallback: profile_row_fallback,
            onTap: onTap,
          ),
          AiSection(
            title: ai_section_title,
            label: ai_section_label,
            label2: ai_section_label2,
            label3: ai_section_label3,
            label4: ai_section_label4,
            fallback: ai_section_fallback,
            onTap: onTap,
          ),
          InfoSection(
            title: info_section_title,
            fallback: info_section_fallback,
            fallback2: info_section_fallback2,
            onTap: onTap,
            onTap2: onTap2,
          ),
        ],
      );
}
