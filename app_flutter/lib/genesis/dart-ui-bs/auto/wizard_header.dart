// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__trade_builder__trade_builder_home:_WizardHeader (בנייה-חכמה main) · צרור-3 · props-שורש: label, label2, fallback, fallback2
// התוכן: new/dart-data-bs/auto/screens__trade_builder__trade_builder_home_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/config_theme.dart';

class WizardHeader extends StatelessWidget {
  WizardHeader({required this.label, required this.label2, required this.fallback, required this.fallback2});
  final String label;
  final String label2;
  final String fallback;
  final String fallback2;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${label}$_kWizardStep${label2}$_kWizardTotal',
      child: Container(
        padding: const EdgeInsets.all(BsTokens.space4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(cfgRadius(context)),
          border: Border.all(color: const Color(0xFFEDEDED)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: CfgText(
                    'trade_builder_home.t01',
                    fallback,
                    style: TextStyle(
                      color: BsTokens.inkLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
                CfgText(
                  'trade_builder_home.t02',
                  fallback2,
                  style: TextStyle(color: BsTokens.mutedLight, fontSize: 12.5),
                ),
              ],
            ),
            const SizedBox(height: BsTokens.space3),
            Row(
              children: [
                for (var i = 0; i < _kWizardTotal; i++) ...[
                  Expanded(
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: i < _kWizardStep
                            ? BsTokens.brand
                            : const Color(0xFFEDEDED),
                        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
                      ),
                    ),
                  ),
                  if (i < _kWizardTotal - 1) const SizedBox(width: 4),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

const int _kWizardStep = 1;

const int _kWizardTotal = 6;
