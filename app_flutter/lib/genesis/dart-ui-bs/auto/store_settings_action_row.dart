// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__store_settings_screen:_ActionRow (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class StoreSettingsActionRow extends StatelessWidget {
  const StoreSettingsActionRow({
    required this.label,
    required this.buttonLabel,
    required this.onTap,
  });

  final String label;
  final String buttonLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(label, style: const TextStyle(color: BsTokens.inkLight)),
      trailing: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          // AA על ListTile לבן (redAccent=3.19:1 נכשל) — token חוזה 9.
          foregroundColor: BsTokens.dangerDark,
        ),
        child: Text(buttonLabel),
      ),
    );
  }
}
