// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__trade_builder__trade_builder_home:_AddTradeButton (בנייה-חכמה main) · צרור-1 · props-שורש: label, fallback
// התוכן: new/dart-data-bs/auto/screens__trade_builder__trade_builder_home_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/app_theme.dart';

class AddTradeButton extends StatelessWidget {
  AddTradeButton({required this.label, required this.fallback, required this.onTap});
  final String label;
  final String fallback;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // composite hide: whole 'הוסף ענף' pill gone when the org hides this element
    return CfgVisible(
      'trade_builder_home.add',
      child: Semantics(
        button: true,
        label: label,
        child: Material(
          color: BsTokens.brand,
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          child: InkWell(
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: CfgText(
                'trade_builder_home.add',
                fallback,
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
    );
  }
}
