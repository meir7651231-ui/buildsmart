// 🧼 אטום · StepBtn — כפתור-מדרגה 48dp (a11y) עם מצב-מנוטרל (onTap=null ⇒ צבע-כבוי).
// מוצא: screens__store_screen.dart:2292 (_StepBtn). ה-tooltip נבחר במקור לפי icon==add
// (t_c3f9ac23 / t_f3943fe9) — כאן label מוזרק ע״י הקופסה, ההחלטה נשארת בחיווט.
import 'package:flutter/material.dart';

class StepBtn extends StatelessWidget {
  const StepBtn({
    required this.icon, required this.label,
    required this.enabledColor, required this.disabledColor,
    this.onTap, super.key,
  });
  final IconData icon;
  final String label;
  final Color enabledColor, disabledColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: label,
        child: Semantics(
          button: true,
          label: label,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: Icon(icon, size: 18, color: onTap != null ? enabledColor : disabledColor),
              ),
            ),
          ),
        ),
      );
}
