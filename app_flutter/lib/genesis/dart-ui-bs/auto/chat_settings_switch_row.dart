// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__chat_settings_screen:_SwitchRow (בנייה-חכמה main) · צרור-2 · props-שורש: fallback
// התוכן: new/dart-data-bs/auto/screens__chat_settings_screen_content.dart
// משרת-גם (זהה-מבנית): screens__store_settings_screen:_SwitchRow
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';

class ChatSettingsSwitchRow extends StatelessWidget implements _Inert {
  ChatSettingsSwitchRow({required this.fallback, 
    required this.label,
    required this.value,
    required this.onChanged,
    this.underConstruction = false,
  });
  final String fallback;

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  final bool underConstruction;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(label, style: const TextStyle(color: BsTokens.inkLight)),
      subtitle: underConstruction
          ? CfgText(
              'chat_settings_screen.t15',
              fallback,
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
            )
          : null,
      value: value,
      activeColor: BsTokens.brand,
      onChanged: onChanged,
    );
  }
}

abstract class _Inert {
  bool get underConstruction;
}
