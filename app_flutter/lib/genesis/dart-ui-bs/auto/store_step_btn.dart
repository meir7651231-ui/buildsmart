// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__store_screen:_StepBtn (בנייה-חכמה main) · צרור-1 · props-שורש: message, message2, label, label2
// התוכן: new/dart-data-bs/auto/screens__store_screen_content.dart
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class StoreStepBtn extends StatelessWidget {
  StoreStepBtn({required this.message, required this.message2, required this.label, required this.label2, required this.icon, this.onTap});
  final String message;
  final String message2;
  final String label;
  final String label2;

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: icon == Icons.add ? message : message2,
      child: Semantics(
        button: true,
        label: icon == Icons.add ? label : label2,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          // ≥48dp tap target (a11y) — icon visuals unchanged.
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: Icon(
                icon,
                size: 18,
                color: onTap != null ? BsTokens.brand : const Color(0xFF444444),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
