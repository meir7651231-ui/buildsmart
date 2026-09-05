// 🧼 אטום · FilledCtaButton — כפתור-CTA ראשי ברוחב-מלא (FilledButton, 16/w800,
// רדיוס-כרטיס). מוצא: גוף _ProfileCard, כפתור-העריכה (screens__home_shell.dart:
// 1677-1707).
// התרת-סבך: CfgVisible/CfgText home.profilecard.editCta ⇒ עטיפת-הקופסה + labelSlot;
// pop+push של מסך-העריכה ⇒ onPressed. היו צרובים: BsTokens.brand · bsOnAccent ·
// BsTokens.radiusCard · BsTokens.space3 ⇒ params.
// שונה מ-PillButton שבמדף (Material+InkWell, גלולה, 14/w800, padding קבוע 16/12,
// מצב-מנוטרל) — כאן FilledButton-של-הערכה, רוחב-מלא, רדיוס-כרטיס מוזרק, בלי
// מצב-מנוטרל; עוגנים שונים בגוף ⇒ אטום נפרד, לא כפילות-מדף.
import 'package:flutter/material.dart';

class FilledCtaButton extends StatelessWidget {
  const FilledCtaButton({
    required this.label,
    required this.onPressed,
    required this.fillColor,
    required this.textColor,
    required this.radius,
    required this.vPad,
    this.labelSlot,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final Color fillColor, textColor;
  final double radius, vPad;

  /// slot-דריסה לתווית (CfgText בקופסה); null ⇒ Text(label).
  final Widget? labelSlot;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: fillColor,
            padding: EdgeInsets.symmetric(vertical: vPad),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
          child: labelSlot ??
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
        ),
      );
}
