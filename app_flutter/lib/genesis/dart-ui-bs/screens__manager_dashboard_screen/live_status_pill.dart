// 🧼 אטום · LiveStatusPill — גלולת-סטטוס עם נקודה + טקסט. מוצא: _LivePill.
// התרת-סבך: connectionStatusProvider ⇒ הקופסה מזריקה text/fg/bg מ-connectionPillContent.
import 'package:flutter/material.dart';

class LiveStatusPill extends StatelessWidget {
  const LiveStatusPill({
    required this.text, required this.textColor, required this.fillColor,
    required this.pillRadius, required this.horizontalPadding, super.key,
  });

  final String text;
  final Color textColor, fillColor;
  final double pillRadius;

  /// BsTokens.space3 במקור — מוזרק (טוקן-עיצוב כ-param).
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 5),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(pillRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: textColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 12.5),
            ),
          ],
        ),
      );
}
