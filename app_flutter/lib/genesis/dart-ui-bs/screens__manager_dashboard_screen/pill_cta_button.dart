// 🧼 אטום · PillCtaButton — כפתור-גלולה פרמטרי (מילוי/מתאר, ריפוד/גופן מוזרקים).
// איחד: _AdvanceButton (h14/v8, fs13) · _SheetAdvanceButton (v14, fs15, ממורכז) ·
// _ApprovalButton (v9, fs13.5, ממורכז, מתאר-אופציונלי) · כפתור-הרגרסיה (v12, fs14).
// נבדק PillButton מהמדף — ריפוד/גופן קבועים (16/12, fs14) ואין וריאנט-מתאר ⇒
// המקור-הקדוש (4 פיגומים שונים) מחייב אטום פרמטרי, לא שכפול-מדף.
// התרת-סבך: CfgVisible/CfgText/HelpTarget ⇒ עטיפות-קופסה; onTap = הפעולה שהוזרמה.
import 'package:flutter/material.dart';

class PillCtaButton extends StatelessWidget {
  const PillCtaButton({
    required this.label, required this.onTap, required this.fillColor,
    required this.textColor, required this.pillRadius, required this.fontSize,
    required this.verticalPadding,
    this.horizontalPadding = 0, this.borderColor, this.centered = false,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final Color fillColor, textColor;
  final Color? borderColor;
  final double pillRadius, fontSize, verticalPadding, horizontalPadding;

  /// true ⇒ מיושר-מרכז ותופס-רוחב (וריאנט-הגיליון/האישור); false ⇒ תוכן-בלבד.
  final bool centered;

  @override
  Widget build(BuildContext context) => Material(
        color: fillColor,
        borderRadius: BorderRadius.circular(pillRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(pillRadius),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: verticalPadding,
              horizontal: horizontalPadding,
            ),
            alignment: centered ? Alignment.center : null,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(pillRadius),
              border: borderColor == null ? null : Border.all(color: borderColor!),
            ),
            child: Text(
              label,
              textAlign: centered ? TextAlign.center : null,
              style: TextStyle(
                color: textColor,
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      );
}
