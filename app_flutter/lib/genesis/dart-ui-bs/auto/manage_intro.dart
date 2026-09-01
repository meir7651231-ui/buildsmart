// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__manager_dashboard_screen:_ManageIntro (בנייה-חכמה main) · צרור-1 · props-שורש: fallback
// התוכן: new/dart-data-bs/auto/screens__manager_dashboard_screen_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/config_theme.dart';

class ManageIntro extends StatelessWidget {
  ManageIntro({required this.fallback});
  final String fallback;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: BsTokens.space4,
        vertical: BsTokens.space3,
      ),
      decoration: BoxDecoration(
        color: BsTokens.brand.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(cfgRadius(context)),
      ),
      child: CfgText(
        'manager.manage.intro',
        fallback,
        style: TextStyle(
          color: BsTokens.inkLight,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
      ),
    );
  }
}
