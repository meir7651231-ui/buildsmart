// 🧼 אטום · TintedBanner — באנר-פתיח במילוי-רך ברוחב-מלא. מוצא: _ManageIntro.
// התרת-סבך: brand.withValues(alpha:.08) ⇒ fillColor מוזרק (פיגמנט בקופסה);
// CfgText ⇒ הטקסט-האפקטיבי מהקופסה (manageIntroContent).
import 'package:flutter/material.dart';

class TintedBanner extends StatelessWidget {
  const TintedBanner({
    required this.text, required this.fillColor, required this.textColor,
    required this.radius, required this.padding,
    this.fontSize = 13.5, this.lineHeight = 1.3, super.key,
  });

  final String text;
  final Color fillColor, textColor;
  final double radius, fontSize, lineHeight;

  /// EdgeInsets.symmetric(horizontal: space4, vertical: space3) במקור.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            height: lineHeight,
          ),
        ),
      );
}
