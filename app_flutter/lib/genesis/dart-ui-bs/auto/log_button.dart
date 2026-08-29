// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__tasks_screen:_LogButton (בנייה-חכמה main) · צרור-1 · props-שורש: fallback
// התוכן: new/dart-data-bs/auto/screens__tasks_screen_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/config_theme.dart';

class LogButton extends StatelessWidget {
  LogButton({required this.fallback, required this.onTap});
  final String fallback;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) =>
      // composite hide: whole work-log pill gone when the org hides this element
      CfgVisible(
        'tasks_screen.log_btn',
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(cfgRadius(context)),
          elevation: 1,
          shadowColor: Colors.black26,
          child: InkWell(
            borderRadius: BorderRadius.circular(cfgRadius(context)),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.all(BsTokens.space4),
              child: CfgText(
                'tasks_screen.log_btn',
                fallback,
                style: TextStyle(
                  color: BsTokens.inkLight,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      );
}
