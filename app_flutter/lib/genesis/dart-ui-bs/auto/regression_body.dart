// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__manager_dashboard_screen:_RegressionBody (בנייה-חכמה main) · צרור-1 · props-שורש: fallback, title, body, fallback2
// התוכן: new/dart-data-bs/auto/screens__manager_dashboard_screen_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/app_theme.dart';

class RegressionBody extends StatelessWidget {
  RegressionBody({required this.fallback, required this.title, required this.body, required this.fallback2, required this.onOpen});
  final String fallback;
  final String title;
  final String body;
  final String fallback2;

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CfgText(
          'manager_dashboard_screen.regression_intro',
          fallback,
          style: TextStyle(
            color: BsTokens.inkLight,
            fontSize: 13,
            height: 1.35,
          ),
        ),
        const SizedBox(height: BsTokens.space3),
        // #31 — help mode rings + explains; this whole body sits inside the
        // kDebugMode gate, so the HelpTarget is dormant in release just like
        // the button itself.
        HelpTarget(
          title: title,
          body: body,
          // giant · composite hide: an org that hides
          // 'manager.manage.regression.open' removes the WHOLE button (not an
          // empty shell — CfgText alone would blank only the label). CfgVisible
          // wraps the outer button; absent config ⇒ child verbatim ⇒
          // byte-identical.
          child: CfgVisible(
            'manager.manage.regression.open',
            child: Material(
              color: BsTokens.brand,
              borderRadius: BorderRadius.circular(BsTokens.radiusPill),
              child: InkWell(
                borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                onTap: onOpen,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: CfgText(
                    'manager.manage.regression.open',
                    fallback2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: bsOnAccent(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
