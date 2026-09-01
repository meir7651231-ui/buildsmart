// 🧼 אטום · CreditBar — פס-ניצול-אשראי (מסילה בהירה + מילוי בצבע-הסטטוס).
// מוצא: _CreditBar. התרת-סבך: pct⇒fraction מחושב בקופסה; תווית-הנגישות
// (creditBarContent.semanticsTpl) מפורמטת בקופסה; trackColor = שקע-theme מוזרק.
import 'package:flutter/material.dart';

class CreditBar extends StatelessWidget {
  const CreditBar({
    required this.fraction, required this.color, required this.trackColor,
    required this.pillRadius, this.minHeight = 8, this.semanticsLabel, super.key,
  });

  final double fraction;
  final Color color, trackColor;
  final double pillRadius, minHeight;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) => Semantics(
        label: semanticsLabel,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(pillRadius),
          child: LinearProgressIndicator(
            value: fraction.clamp(0.0, 1.0),
            minHeight: minHeight,
            backgroundColor: trackColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      );
}
