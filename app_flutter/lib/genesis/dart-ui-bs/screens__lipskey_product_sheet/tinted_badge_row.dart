// 🧼 אטום · TintedBadgeRow — שורת-כותרת-קבוצה: גלולת-גוון ממוסגרת + טקסט-נלווה.
// מוצא: screens__lipskey_product_sheet.dart:1110-1148 (כותרת צד-חיבור: 📐 צד N + N חלקים).
// הטקסטים (תבניות connectionSideTpl/sizeOnlyTpl/partsCountTpl ב-content) מפורמטים בקופסה;
// גוני-הכתום (0x22FF7A18 / 0x55FF7A18 / 0xFFFF9D4D) = פיגמנטים.
import 'package:flutter/material.dart';

class TintedBadgeRow extends StatelessWidget {
  const TintedBadgeRow({
    required this.badgeText,
    required this.trailingText,
    required this.badgeBgColor,
    required this.badgeBorderColor,
    required this.badgeFgColor,
    required this.trailingColor,
    super.key,
  });
  final String badgeText, trailingText;
  final Color badgeBgColor, badgeBorderColor, badgeFgColor, trailingColor;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: badgeBgColor,
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: badgeBorderColor),
              ),
              child: Text(
                badgeText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: badgeFgColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(trailingText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: trailingColor, fontSize: 11)),
          ),
        ],
      );
}
