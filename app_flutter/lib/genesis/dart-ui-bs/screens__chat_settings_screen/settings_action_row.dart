// 🧼 אטום · SettingsActionRow — שורת-פעולה: תווית + כפתור-טקסט בקצה.
// מוצא: screens__chat_settings_screen.dart · _ActionRow (שורות 1081–1108), verbatim.
// דגל destructive במקור בחר צבע (redAccent/brand) — ההכרעה עברה לקופסה (חוק-5):
// האטום מקבל buttonColor מוכן, בלי לדעת אם הפעולה הרסנית.
import 'package:flutter/material.dart';

class SettingsActionRow extends StatelessWidget {
  const SettingsActionRow({
    required this.label,
    required this.buttonLabel,
    required this.onTap,
    required this.inkColor,
    required this.buttonColor,
    super.key,
  });

  final String label;
  final String buttonLabel;
  final VoidCallback onTap;
  final Color inkColor;
  final Color buttonColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(label, style: TextStyle(color: inkColor)),
      trailing: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(foregroundColor: buttonColor),
        child: Text(buttonLabel),
      ),
    );
  }
}
