// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__manager_dashboard_screen:_SheetAdvanceButton (בנייה-חכמה main) · צרור-1 · props-שורש: title, body
// התוכן: new/dart-data-bs/auto/screens__manager_dashboard_screen_content.dart
import 'package:flutter/material.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'bs_tokens.dart';

class SheetAdvanceButton extends StatelessWidget {
  SheetAdvanceButton({required this.title, required this.body, required this.label, required this.onPressed});
  final String title;
  final String body;

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    // #31 — the detail-sheet stage-advance; in help mode the HelpTarget rings +
    // explains it instead of advancing.
    return HelpTarget(
      title: title,
      body:
          body,
      child: Material(
        color: const Color(0xFF1F8A4C),
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(BsTokens.radiusPill),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
