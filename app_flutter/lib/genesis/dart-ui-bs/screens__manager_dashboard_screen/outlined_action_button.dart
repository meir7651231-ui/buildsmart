// 🧼 אטום · OutlinedActionButton — כפתור-מתאר עם מוביל (אייקון/emoji/ספינר) + תווית.
// איחד 6 מופעי OutlinedButton.icon זהי-סגנון: חשבונית/קבלה/תעודת-משלוח (גיליון-
// ההזמנה), ייבוא-CSV (טאב-הלקוחות), צ׳אט-עם-הלקוח, הסבר-אשראי. הסגנון המשותף:
// foreground=brandDark, side=brand, ריפוד-אנכי 11, רדיוס 12, w800 fs14 — מוזרק.
// התרת-סבך: printDocument/lookup/ניווט = onPressed מהקופסה; מצב-busy = החלפת
// leading בספינר ע"י הקופסה + onPressed=null.
import 'package:flutter/material.dart';

class OutlinedActionButton extends StatelessWidget {
  const OutlinedActionButton({
    required this.leading, required this.label,
    required this.foregroundColor, required this.borderColor,
    this.onPressed, this.verticalPadding = 11, this.fontSize = 14,
    this.radius = 12, super.key,
  });

  final Widget leading;
  final String label;
  final Color foregroundColor, borderColor;
  final VoidCallback? onPressed;
  final double verticalPadding, fontSize, radius;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: onPressed,
        icon: leading,
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor,
          side: BorderSide(color: borderColor),
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          textStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: fontSize),
        ),
      );
}
