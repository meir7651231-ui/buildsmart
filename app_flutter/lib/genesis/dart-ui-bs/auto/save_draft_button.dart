// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__trade_builder__trade_define_step:_SaveDraftButton (בנייה-חכמה main) · צרור-1 · props-שורש: label, fallback
// התוכן: new/dart-data-bs/auto/screens__trade_builder__trade_define_step_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/app_theme.dart';

class SaveDraftButton extends StatelessWidget {
  SaveDraftButton({required this.label, required this.fallback, required this.enabled, required this.onTap});
  final String label;
  final String fallback;

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // composite hide: whole 'שמור טיוטה' pill gone when the org hides this element
    return CfgVisible(
      'trade_define_step.save_draft',
      child: Semantics(
        button: true,
        enabled: enabled,
        label: label,
        child: Material(
          color: enabled ? BsTokens.brand : const Color(0xFFE2E2E2),
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          child: InkWell(
            borderRadius: BorderRadius.circular(BsTokens.radiusPill),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: CfgText(
                'trade_define_step.save_draft',
                fallback,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: enabled ? bsOnAccent(context) : BsTokens.mutedLight,
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
