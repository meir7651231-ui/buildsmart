// 🧼 אטום · SummaryStatStrip — רצועת-סיכום לבנה של N סטטיסטיקות (ערך 20 w800 +
// תווית 12.5 מושתקת). איחד _OrderSummary + _CustomerSummary (מנגנון זהה ×2).
// נבדקו StatTile/BareStat מהמדף — טיפוגרפיה/מבנה שונים (17/12, צל, בלי מסגרת) ⇒
// לא שכפול. הערכים מגיעים מפורמטים מהקופסה ('₪3,150' / '18%').
import 'package:flutter/material.dart';

class SummaryStatStrip extends StatelessWidget {
  const SummaryStatStrip({
    required this.stats, required this.surfaceColor, required this.borderColor,
    required this.valueColor, required this.labelColor, required this.radius,
    required this.padding, super.key,
  });

  final List<({String value, String label})> stats;
  final Color surfaceColor, borderColor, valueColor, labelColor;
  final double radius;

  /// EdgeInsets.symmetric(horizontal: space4, vertical: space4) במקור.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            for (final s in stats)
              Expanded(
                child: Column(
                  children: [
                    Text(
                      s.value,
                      style: TextStyle(
                        color: valueColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.label,
                      style: TextStyle(color: labelColor, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
}
