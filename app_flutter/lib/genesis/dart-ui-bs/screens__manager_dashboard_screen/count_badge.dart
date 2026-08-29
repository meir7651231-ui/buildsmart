// 🧼 אטום · CountBadge — תג-ספירה במילוי-מותג (מספר לבן, minWidth 22).
// מוצא: _CountBadge. התרת-סבך: '$count' + תווית-הנגישות (countBadgeContent
// semanticsTpl) מפורמטים בקופסה; bsOnAccent(context) ⇒ textColor מוזרק.
import 'package:flutter/material.dart';

class CountBadge extends StatelessWidget {
  const CountBadge({
    required this.text, required this.fillColor, required this.textColor,
    required this.pillRadius, this.semanticsLabel, super.key,
  });

  final String text;
  final Color fillColor, textColor;
  final double pillRadius;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) => Semantics(
        label: semanticsLabel,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          constraints: const BoxConstraints(minWidth: 22),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(pillRadius),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
}
