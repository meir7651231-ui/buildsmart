// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__store_settings_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/catalog_settings_placeholder_row.dart';
import '../dart-ui-bs/auto/chat_settings_switch_row.dart';
import '../dart-ui-bs/auto/store_settings_action_row.dart';
import '../dart-ui-bs/auto/store_settings_section_tile.dart';
import '../dart-ui-bs/screens__store_settings_screen/settings_number_row.dart';
import '../dart-ui-bs/screens__store_settings_screen/settings_validated_text_row.dart';
import '../dart-data-bs/auto/screens__store_settings_screen_content.dart';
import '../dart-data-bs/screens__store_settings_screen_content.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class StoreSettingsScreenTokens {
  const StoreSettingsScreenTokens({required this.cursorColor, required this.fieldWidth, required this.fillColor, required this.hintColor, required this.inkColor, required this.labelColor, required this.mutedColor});
  final Color cursorColor;
  final double fieldWidth;
  final Color fillColor;
  final Color hintColor;
  final Color inkColor;
  final Color labelColor;
  final Color mutedColor;
}

class StoreSettingsScreenComposed extends StatelessWidget {
  const StoreSettingsScreenComposed({required this.onChanged, required this.onTap, required this.buttonLabel, required this.children, required this.errorText, required this.fallback, required this.hint, required this.label, required this.subtitleNote, required this.underConstruction, required this.value, required this.value2, required this.value22, required this.t, super.key});

  final VoidCallback onChanged;
  final VoidCallback onTap;
  final String buttonLabel;
  final List<Widget> children;
  final String? errorText;
  final String fallback;
  final String hint;
  final String label;
  final String? subtitleNote;
  final bool underConstruction;
  final String value;
  final bool value2;
  final int value22;
  final StoreSettingsScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          StoreSettingsSectionTile(
            fallback: store_settings_section_tile_fallback,
            emoji: storeSettingsScreenContent.emoji,
            title: storeSettingsScreenContent.title,
            children: children,
            underConstruction: underConstruction,
          ),
          SettingsValidatedTextRow(
            label: label,
            hint: hint,
            value: value,
            onChanged: onChanged,
            labelColor: t.labelColor,
            inkColor: t.inkColor,
            mutedColor: t.mutedColor,
            cursorColor: t.cursorColor,
            hintColor: t.hintColor,
            fillColor: t.fillColor,
            errorText: errorText,
            subtitleNote: subtitleNote,
          ),
          ChatSettingsSwitchRow(
            fallback: fallback,
            label: label,
            value: value2,
            onChanged: onChanged,
            underConstruction: underConstruction,
          ),
          CatalogSettingsPlaceholderRow(
            fallback: fallback,
            onTap: onTap,
            label: label,
          ),
          SettingsNumberRow(
            label: label,
            value: value22,
            onChanged: onChanged,
            inkColor: t.inkColor,
            mutedColor: t.mutedColor,
            cursorColor: t.cursorColor,
            fillColor: t.fillColor,
            subtitleNote: subtitleNote,
            fieldWidth: t.fieldWidth,
          ),
          StoreSettingsActionRow(
            label: label,
            buttonLabel: buttonLabel,
            onTap: onTap,
          ),
        ],
      );
}
