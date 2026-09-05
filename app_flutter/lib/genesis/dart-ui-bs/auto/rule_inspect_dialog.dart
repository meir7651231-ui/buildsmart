// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__trade_builder__connection_rule_studio:_RuleInspectDialog (בנייה-חכמה main) · צרור-1 · מודל-שוטח: 1 שדות · props-שורש: fallback, fallback2, fallback3, onPressed, onPressed2, methodLabelHe
// התוכן: new/dart-data-bs/auto/screens__trade_builder__connection_rule_studio_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';

class RuleInspectDialog extends StatelessWidget {
  RuleInspectDialog({required this.fallback, required this.fallback2, required this.fallback3, required this.methodLabelHe, required this.onPressed, required this.onPressed2, });
  final String fallback;
  final String fallback2;
  final String fallback3;
  final String methodLabelHe;
  final VoidCallback onPressed;
  final VoidCallback onPressed2;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: CfgText(
          'connection_rule_studio.rule_title',
          fallback,
          style: TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w800,
            fontSize: 16),
        ),
        content: Text(
          methodLabelHe,
          style: const TextStyle(color: BsTokens.inkLight, fontSize: 14),
        ),
        actions: [
          // composite hide: whole delete button gone when the org hides this element
          CfgVisible(
            'connection_rule_studio.delete_rule',
            child: TextButton(
              onPressed: onPressed,
              child: CfgText(
                'connection_rule_studio.delete_rule',
                fallback2,
                style: TextStyle(
                  color: BsTokens.dangerDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          // composite hide: whole close button gone when the org hides this element
          CfgVisible(
            'connection_rule_studio.close',
            child: TextButton(
              onPressed: onPressed2,
              style: TextButton.styleFrom(foregroundColor: BsTokens.brand),
              child: CfgText(
                'connection_rule_studio.close',
                fallback3,
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
