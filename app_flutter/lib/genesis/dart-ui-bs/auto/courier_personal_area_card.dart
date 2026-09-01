// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__courier_profile_screen:_CourierPersonalAreaCard (בנייה-חכמה main) · צרור-1 · props-שורש: title, body, fallback, fallback2, title2, body2, fallback3, fallback4, title3, body3, fallback5, fallback6, title4, body4, fallback7, fallback8, onTap, onTap2, onTap3, onTap4
// התוכן: new/dart-data-bs/auto/screens__courier_profile_screen_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/config_theme.dart';

class CourierPersonalAreaCard extends StatelessWidget {
  CourierPersonalAreaCard({required this.title, required this.body, required this.fallback, required this.fallback2, required this.title2, required this.body2, required this.fallback3, required this.fallback4, required this.title3, required this.body3, required this.fallback5, required this.fallback6, required this.title4, required this.body4, required this.fallback7, required this.fallback8, required this.onTap, required this.onTap2, required this.onTap3, required this.onTap4});
  final String title;
  final String body;
  final String fallback;
  final String fallback2;
  final String title2;
  final String body2;
  final String fallback3;
  final String fallback4;
  final String title3;
  final String body3;
  final String fallback5;
  final String fallback6;
  final String title4;
  final String body4;
  final String fallback7;
  final String fallback8;
  final VoidCallback onTap;
  final VoidCallback onTap2;
  final VoidCallback onTap3;
  final VoidCallback onTap4;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(cfgRadius(context)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      // Transparent Material inside the decorated card so the ListTiles' ink
      // ripples paint above the card bg instead of being hidden by it.
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            HelpTarget(
              title: title,
              body:
                  body,
              child: ListTile(
                leading: const Text('🕐', style: TextStyle(fontSize: 20)),
                title: CfgText(
                  'courier.personal.attendance_title',
                  fallback,
                  style: TextStyle(color: BsTokens.inkLight, fontSize: 15),
                ),
                subtitle: CfgText(
                  'courier_profile_screen.attendance_subtitle',
                  fallback2,
                  style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
                ),
                trailing: const Icon(
                  Icons.chevron_left,
                  color: BsTokens.mutedLight,
                ),
                onTap:
                    onTap,
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF2F3F5)),
            HelpTarget(
              title: title2,
              body: body2,
              child: ListTile(
                leading: const Text('📄', style: TextStyle(fontSize: 20)),
                title: CfgText(
                  'courier.personal.forms_title',
                  fallback3,
                  style: TextStyle(color: BsTokens.inkLight, fontSize: 15),
                ),
                subtitle: CfgText(
                  'courier_profile_screen.forms_subtitle',
                  fallback4,
                  style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
                ),
                trailing: const Icon(
                  Icons.chevron_left,
                  color: BsTokens.mutedLight,
                ),
                onTap:
                    onTap2,
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF2F3F5)),
            HelpTarget(
              title: title3,
              body:
                  body3,
              child: ListTile(
                leading: const Text('🪪', style: TextStyle(fontSize: 20)),
                title: CfgText(
                  'courier.personal.certs_title',
                  fallback5,
                  style: TextStyle(color: BsTokens.inkLight, fontSize: 15),
                ),
                subtitle: CfgText(
                  'courier_profile_screen.certs_subtitle',
                  fallback6,
                  style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
                ),
                trailing: const Icon(
                  Icons.chevron_left,
                  color: BsTokens.mutedLight,
                ),
                onTap:
                    onTap3,
              ),
            ),
            const Divider(height: 1, color: Color(0xFFF2F3F5)),
            HelpTarget(
              title: title4,
              body:
                  body4,
              child: ListTile(
                leading: const Text('💰', style: TextStyle(fontSize: 20)),
                title: CfgText(
                  'courier.personal.payslips_title',
                  fallback7,
                  style: TextStyle(color: BsTokens.inkLight, fontSize: 15),
                ),
                subtitle: CfgText(
                  'courier_profile_screen.payslips_subtitle',
                  fallback8,
                  style: TextStyle(color: BsTokens.mutedLight, fontSize: 12),
                ),
                trailing: const Icon(
                  Icons.chevron_left,
                  color: BsTokens.mutedLight,
                ),
                // reuse כמו-שהוא — ה-sheet role-agnostic ומוכן-לשרת (#86.5).
                onTap: onTap4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
