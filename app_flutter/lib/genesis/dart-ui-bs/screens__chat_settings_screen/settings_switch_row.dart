// 🧼 אטום · SettingsSwitchRow — שורת-מתג בהגדרות.
// מוצא: screens__chat_settings_screen.dart · _SwitchRow (שורות 863–894), verbatim ויזואלית.
// underConstruction הוחלף ב-subtitleNote מוזרק (התווית "בבנייה — עדיין לא משפיע" באה
// מהתוכן; null ⇒ אין תת-כותרת). סימון _Inert לספירת-פעילים = ידע-קופסה, לא של האטום.
import 'package:flutter/material.dart';

class SettingsSwitchRow extends StatelessWidget {
  const SettingsSwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.inkColor,
    required this.mutedColor,
    required this.activeColor,
    this.subtitleNote,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color inkColor;
  final Color mutedColor;
  final Color activeColor;

  /// null ⇒ no subtitle row.
  final String? subtitleNote;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(label, style: TextStyle(color: inkColor)),
      subtitle: subtitleNote == null
          ? null
          : Text(
              subtitleNote!,
              style: TextStyle(color: mutedColor, fontSize: 12),
            ),
      value: value,
      activeColor: activeColor,
      onChanged: onChanged,
    );
  }
}
