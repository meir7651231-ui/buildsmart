// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__manager_dashboard_screen:_AdvanceButton (בנייה-חכמה main) · צרור-1 · props-שורש: fallback
// התוכן: new/dart-data-bs/auto/screens__manager_dashboard_screen_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/app_theme.dart';

class AdvanceButton extends StatelessWidget {
  AdvanceButton({required this.fallback, required this.onPressed});
  final String fallback;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // giant · composite hide: an org that hides 'manager.orders.advance'
    // removes the WHOLE advance pill (not an empty shell — CfgText alone would
    // blank only the label). CfgVisible wraps the outer button; absent config
    // ⇒ child verbatim ⇒ byte-identical.
    return CfgVisible(
      'manager.orders.advance',
      child: Material(
        color: BsTokens.brand,
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: CfgText(
              'manager.orders.advance',
              fallback,
              style: TextStyle(
                color: bsOnAccent(context),
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
