// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__intel__intel_tab:_IntelIntro (בנייה-חכמה main) · צרור-1 · props-שורש: label, fallback, fallback2
// התוכן: new/dart-data-bs/auto/screens__intel__intel_tab_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';

class IntelIntro extends StatelessWidget {
  IntelIntro({required this.label, required this.fallback, required this.fallback2});
  final String label;
  final String fallback;
  final String fallback2;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      header: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsetsDirectional.all(BsTokens.space4),
        decoration: BoxDecoration(
          color: BsTokens.brand.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(BsTokens.radiusCard),
          border: Border.all(color: BsTokens.brand.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CfgText(
              'intel_tab.t01',
              fallback,
              style: TextStyle(
                color: BsTokens.inkLight,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            SizedBox(height: BsTokens.spaceHair),
            CfgText(
              'intel_tab.t02',
              fallback2,
              style: TextStyle(color: BsTokens.mutedLight, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
