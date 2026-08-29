// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__catalog_settings_screen:_ProfileRow (בנייה-חכמה main) · צרור-1 · props-שורש: fallback, onTap
// התוכן: new/dart-data-bs/auto/screens__catalog_settings_screen_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';

class ProfileRow extends StatelessWidget {
  ProfileRow({required this.fallback, required this.onTap});
  final String fallback;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: Theme.of(context).colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: const Text('👤', style: TextStyle(fontSize: 22)),
        title: CfgText(
          'catalog_settings_screen.t06',
          fallback,
          style: TextStyle(
            color: BsTokens.inkLight,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.chevron_left, color: Colors.black54),
        onTap: onTap,
      ),
    );
  }
}
