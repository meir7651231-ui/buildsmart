// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__courier_attendance_screen:_SendReportButton (בנייה-חכמה main) · צרור-1 · props-שורש: title, body
// התוכן: new/dart-data-bs/auto/screens__courier_attendance_screen_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'bs_tokens.dart';
import 'package:buildsmart/theme/app_theme.dart';

class CourierAttendanceSendReportButton extends StatelessWidget {
  CourierAttendanceSendReportButton({required this.title, required this.body, 
    required this.enabled,
    required this.label,
    required this.onPressed,
  });
  final String title;
  final String body;

  final bool enabled;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // excludeSemantics — the inner Text equals the label (F-50).
    return HelpTarget(
      title: title,
      body:
          body,
      child: Semantics(
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
      ),
    );
  }
}
