// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__notif_settings_screen:_SnoozeSheet (בנייה-חכמה main) · צרור-1 · props-שורש: label, label2, label3, label4, fallback, onTap
// התוכן: new/dart-data-bs/auto/screens__notif_settings_screen_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';

class SnoozeSheet extends StatelessWidget {
  SnoozeSheet({required this.label, required this.label2, required this.label3, required this.label4, required this.fallback, required this.onTap});
  final String label;
  final String label2;
  final String label3;
  final String label4;
  final String fallback;
  final VoidCallback onTap;

  static final _options = [
    (mins: 15, label: label),
    (mins: 60, label: label2),
    (mins: 240, label: label3),
    (mins: 1440, label: label4),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: CfgText(
              'notif_settings_screen.t06',
              fallback,
              style: TextStyle(
                color: BsTokens.inkLight,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF5F5F5), height: 1),
          ..._options.map(
            (o) => ListTile(
              title: Text(
                o.label,
                style: const TextStyle(color: BsTokens.inkLight, fontSize: 15),
              ),
              trailing: const Icon(
                Icons.chevron_left,
                color: Color(0xFF888888),
              ),
              onTap: onTap,
            ),
          ),
        ],
      ),
    );
  }
}
