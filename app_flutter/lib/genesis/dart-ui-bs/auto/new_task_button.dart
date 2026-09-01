// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__tasks_screen:_NewTaskButton (בנייה-חכמה main) · צרור-1 · props-שורש: fallback
// התוכן: new/dart-data-bs/auto/screens__tasks_screen_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/config_theme.dart';

class NewTaskButton extends StatelessWidget {
  NewTaskButton({required this.fallback, required this.onTap});
  final String fallback;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) =>
      // composite hide: whole 'משימה חדשה' pill gone when the org hides this element
      CfgVisible(
        'tasks_screen.new_task',
        child: Material(
          color: BsTokens.brand,
          borderRadius: BorderRadius.circular(cfgRadius(context)),
          elevation: 1,
          shadowColor: Colors.black26,
          child: InkWell(
            key: const ValueKey('task-new'),
            borderRadius: BorderRadius.circular(cfgRadius(context)),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(BsTokens.space4),
              child: CfgText(
                'tasks_screen.new_task',
                fallback,
                style: TextStyle(
                  color: bsOnAccent(context),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      );
}
