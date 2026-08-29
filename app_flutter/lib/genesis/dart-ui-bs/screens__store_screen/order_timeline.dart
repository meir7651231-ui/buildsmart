// 🧼 אטום · OrderTimeline — ציר-שלבי-הזמנה: עיגולי-אייקון + קווי-חיבור; כל שלב עד
// currentIndex צבוע-מבטא, המורחקים כבויים. מוצא: screens__store_screen.dart:4324
// (_OrderTimeline). _steps הצרוב (6 שלבי kManagerOrderFlow — orderStages ב-content)
// ⇒ steps מוזרק; חישוב currentIndex משלב-ההזמנה = קופסה.
import 'package:flutter/material.dart';

typedef OrderTimelineStep = ({String label, IconData icon});

class OrderTimeline extends StatelessWidget {
  const OrderTimeline({
    required this.steps, required this.currentIndex,
    required this.accentColor, required this.onAccentColor, required this.inkColor,
    required this.idleLineColor, required this.idleCircleColor, required this.idleInkColor,
    super.key,
  });
  final List<OrderTimelineStep> steps;
  final int currentIndex;
  final Color accentColor, onAccentColor, inkColor;
  final Color idleLineColor, idleCircleColor, idleInkColor;

  @override
  Widget build(BuildContext context) {
    final cur = currentIndex < 0 ? 0 : currentIndex;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  height: 2,
                  color: i <= cur ? accentColor : idleLineColor,
                ),
              ),
            ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i <= cur ? accentColor : idleCircleColor,
                ),
                alignment: Alignment.center,
                child: Icon(
                  steps[i].icon,
                  size: 18,
                  color: i <= cur ? onAccentColor : idleInkColor,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                steps[i].label,
                style: TextStyle(
                  fontSize: 11,
                  color: i <= cur ? inkColor : idleInkColor,
                  fontWeight: i == cur ? FontWeight.w800 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
