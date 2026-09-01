// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__worker_attendance_screen:_SendReportButton (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/app_theme.dart';

class SendReportButton extends StatelessWidget {
  const SendReportButton({
    required this.enabled,
    required this.label,
    required this.onPressed,
  });

  final bool enabled;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // excludeSemantics — the inner Text equals the label (F-50).
    return Semantics(
      button: enabled,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: enabled ? BsTokens.brand : const Color(0xFFE9EAEC),
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          onTap: enabled ? onPressed : null,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                // bsOnAccent on the brand fill (F-28).
                color: enabled ? bsOnAccent(context) : BsTokens.mutedLight,
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
