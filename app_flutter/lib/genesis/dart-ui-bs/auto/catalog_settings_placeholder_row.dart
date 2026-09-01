// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__catalog_settings_screen:_PlaceholderRow (בנייה-חכמה main) · צרור-1 · props-שורש: fallback, onTap
// התוכן: new/dart-data-bs/auto/screens__catalog_settings_screen_content.dart
// משרת-גם (זהה-מבנית): screens__chat_settings_screen:_PlaceholderRow · screens__notif_settings_screen:_PlaceholderRow · screens__store_settings_screen:_PlaceholderRow
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';

class CatalogSettingsPlaceholderRow extends StatelessWidget {
  CatalogSettingsPlaceholderRow({required this.fallback, required this.onTap, required this.label});
  final String fallback;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(label, style: const TextStyle(color: BsTokens.inkLight)),
      trailing: CfgText(
        'catalog_settings_screen.t12',
        fallback,
        style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
      ),
      onTap: onTap,
    );
  }
}
