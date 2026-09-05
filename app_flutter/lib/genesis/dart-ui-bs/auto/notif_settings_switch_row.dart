// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__notif_settings_screen:_SwitchRow (בנייה-חכמה main) · צרור-2 · props-שורש: fallback, fallback2
// התוכן: new/dart-data-bs/auto/screens__notif_settings_screen_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';

class NotifSettingsSwitchRow extends StatelessWidget implements _Inert {
  NotifSettingsSwitchRow({required this.fallback, required this.fallback2, 
    required this.label,
    required this.value,
    required this.onChanged,
    this.underConstruction = false,
    this.requiresServer = false,
  });
  final String fallback;
  final String fallback2;

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  /// Channels that cannot work without a server (אימייל/SMS/WhatsApp):
  /// rendered disabled with an honest 'דורש חיבור שרת' caption — never fake.
  final bool requiresServer;
  @override
  final bool underConstruction;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(label, style: const TextStyle(color: BsTokens.inkLight)),
      subtitle:
          requiresServer
              ? CfgText(
                'notif_settings_screen.t08',
                fallback,
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
              )
              : underConstruction
              ? CfgText(
                'notif_settings_screen.t09',
                fallback2,
                style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
              )
              : null,
      value: value,
      activeColor: BsTokens.brand,
      onChanged: requiresServer ? null : onChanged,
    );
  }
}

abstract class _Inert {
  bool get underConstruction;
}
