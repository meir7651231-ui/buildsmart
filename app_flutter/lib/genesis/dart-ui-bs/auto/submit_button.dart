// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__worker_app_screen:_SubmitButton (בנייה-חכמה main) · צרור-1 · props-שורש: label, fallback
// התוכן: new/dart-data-bs/auto/screens__worker_app_screen_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/app_theme.dart';

class SubmitButton extends StatelessWidget {
  SubmitButton({required this.label, required this.fallback, required this.onPressed, super.key});
  final String label;
  final String fallback;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      // excludeSemantics — the inner Text equals the label (F-50).
      excludeSemantics: true,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        // composite hide: whole button gone when the org hides this element
        child: CfgVisible(
          'worker.action.submit',
          child: Material(
          color: BsTokens.brand,
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          child: InkWell(
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
            onTap: onPressed,
            // WCAG ≥48px tap target — minHeight guarantees it regardless of the
            // text's intrinsic height (a bare padding only got to ~46px).
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: BsTokens.space4,
                  vertical: 12,
                ),
                child: Center(
                  widthFactor: 1,
                  child: CfgText(
                    'worker.action.submit',
                    fallback,
                    style: TextStyle(
                      color: bsOnAccent(context),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }
}

