// 🧼 אטום · MiniStageTracker — עוקב-שלבים מיני: מקטע פר-שלב, מלא עד-וכולל הנוכחי.
// מוצא: _MiniTracker. התרת-סבך: kManagerOrderFlow.length ⇒ stageCount מוזרק
// (האטום לא מכיר את זרימת-ההזמנות; הקופסה מזרימה 6).
import 'package:flutter/material.dart';

class MiniStageTracker extends StatelessWidget {
  const MiniStageTracker({
    required this.stageCount, required this.activeIndex,
    required this.fillColor, required this.trackColor, required this.pillRadius,
    super.key,
  });

  final int stageCount;
  final int activeIndex;
  final Color fillColor, trackColor;
  final double pillRadius;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          for (var i = 0; i < stageCount; i++) ...[
            Expanded(
              child: Container(
                height: 5,
                decoration: BoxDecoration(
                  color: i <= activeIndex ? fillColor : trackColor,
                  borderRadius: BorderRadius.circular(pillRadius),
                ),
              ),
            ),
            if (i < stageCount - 1) const SizedBox(width: 4),
          ],
        ],
      );
}
