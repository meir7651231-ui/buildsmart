// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__smart_project_screen:_ProjectDone (בנייה-חכמה main) · צרור-1 · props-שורש: fallback
// התוכן: new/dart-data-bs/auto/screens__smart_project_screen_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/config_theme.dart';

class ProjectDone extends StatelessWidget {
  ProjectDone({required this.fallback});
  final String fallback;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(BsTokens.space4),
        decoration: BoxDecoration(
          color: const Color(0xFFE9F7EE),
          borderRadius: BorderRadius.circular(cfgRadius(context)),
        ),
        child: CfgText('smart_project_screen.t08', fallback,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Color(0xFF1f6f3f),
                fontWeight: FontWeight.w800,
                fontSize: 15)),
      );
}
