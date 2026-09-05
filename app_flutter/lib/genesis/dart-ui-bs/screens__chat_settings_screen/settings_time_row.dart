// 🧼 אטום · SettingsTimeRow — שורת-בחירת-שעה (תווית + HH:MM + time-picker בהקשה).
// מוצא: screens__chat_settings_screen.dart · _TimeRow (שורות 958–1004), verbatim.
// מאחד גם את screens__notif_settings_screen:_TimeRow (widget-dedup.json, קבוצה n=2 loc=47).
// צבעי-הבוחר (primary/surface של ה-ThemeData המקומי) מוזרקים — היו צרובים במקור.
import 'package:flutter/material.dart';

class SettingsTimeRow extends StatelessWidget {
  const SettingsTimeRow({
    required this.label,
    required this.time,
    required this.onChanged,
    required this.inkColor,
    required this.accentColor,
    required this.pickerSurfaceColor,
    super.key,
  });

  final String label;
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onChanged;
  final Color inkColor;

  /// Trailing HH:MM color and the picker primary color.
  final Color accentColor;
  final Color pickerSurfaceColor;

  String get _formatted =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(label, style: TextStyle(color: inkColor)),
      trailing: Text(
        _formatted,
        style: TextStyle(
          color: accentColor,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (ctx, child) => Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: accentColor,
                surface: pickerSurfaceColor,
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) onChanged(picked);
      },
    );
  }
}
