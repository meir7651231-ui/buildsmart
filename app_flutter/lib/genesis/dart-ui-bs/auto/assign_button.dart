// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__manager_role_assign_sheet:_AssignButton (בנייה-חכמה main) · צרור-1 · props-שורש: fallback
// התוכן: new/dart-data-bs/auto/screens__manager_role_assign_sheet_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/app_theme.dart';

class AssignButton extends StatelessWidget {
  AssignButton({required this.fallback, 
    required this.enabled,
    required this.busy,
    required this.onPressed,
  });
  final String fallback;

  final bool enabled;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? BsTokens.brand : const Color(0xFFE2E2E2),
      borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      child: InkWell(
        key: const ValueKey('role-assign-submit'),
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        onTap: enabled ? onPressed : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: busy
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : CfgText(
                  'manager_role_assign_sheet.t04',
                  fallback,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: enabled ? bsOnAccent(context) : BsTokens.mutedLight,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ),
    );
  }
}
