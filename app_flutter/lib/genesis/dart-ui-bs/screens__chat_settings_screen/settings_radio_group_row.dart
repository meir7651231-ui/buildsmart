// 🧼 אטום · SettingsRadioGroupRow — כותרת-שדה + קבוצת-רדיו גנרית.
// מוצא: screens__chat_settings_screen.dart · _RadioGroupRow (שורות 896–956), verbatim ויזואלית.
// תוויות-האופציות מוזרקות כרשומות (value,label) — התוכן בקובץ-הדאטה, לא כאן.
// underConstruction הוחלף ב-subtitleNote מוזרק (null ⇒ אין); סימון _Inert = ידע-קופסה.
import 'package:flutter/material.dart';

class SettingsRadioGroupRow<T> extends StatelessWidget {
  const SettingsRadioGroupRow({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    required this.labelColor,
    required this.inkColor,
    required this.mutedColor,
    required this.activeColor,
    this.subtitleNote,
    super.key,
  });

  final String label;
  final T value;
  final List<({T value, String label})> options;
  final ValueChanged<T> onChanged;
  final Color labelColor;
  final Color inkColor;
  final Color mutedColor;
  final Color activeColor;

  /// null ⇒ no subtitle row.
  final String? subtitleNote;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: labelColor, fontSize: 13)),
              if (subtitleNote != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    subtitleNote!,
                    style: TextStyle(color: mutedColor, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
        ...options.map(
          (o) => RadioListTile<T>(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(o.label, style: TextStyle(color: inkColor)),
            value: o.value,
            groupValue: value,
            activeColor: activeColor,
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ],
    );
  }
}
