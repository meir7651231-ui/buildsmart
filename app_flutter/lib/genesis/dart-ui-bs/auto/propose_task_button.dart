// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__worker_app_screen:_ProposeTaskButton (בנייה-חכמה main) · צרור-1 · props-שורש: title, body, label, fallback
// התוכן: new/dart-data-bs/auto/screens__worker_app_screen_content.dart
// משרת-גם (זהה-מבנית): screens__worker_app_screen:_GanttButton · screens__worker_app_screen:_DefectsButton
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';

class ProposeTaskButton extends StatelessWidget {
  ProposeTaskButton({required this.title, required this.body, required this.label, required this.fallback, required this.onPressed});
  final String title;
  final String body;
  final String label;
  final String fallback;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: BsTokens.space2),
      child: HelpTarget(
        title: title,
        body:
            body,
        child: Semantics(
          button: true,
          label: label,
          excludeSemantics: true,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            // composite hide: whole button gone when the org hides this element
            child: CfgVisible(
              'worker.action.addTask',
              child: OutlinedButton.icon(
              key: const ValueKey('worker-propose-open'),
              style: OutlinedButton.styleFrom(
                foregroundColor: BsTokens.brandDark,
                side: const BorderSide(color: BsTokens.brand, width: 1.5),
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(
                  horizontal: BsTokens.space4,
                  vertical: 9,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                ),
              ),
              onPressed: onPressed,
              icon: const Text('➕', style: TextStyle(fontSize: 15)),
              label: CfgText(
                'worker.action.addTask',
                fallback,
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
              ),
            ),
            ),
          ),
        ),
      ),
    );
  }
}
