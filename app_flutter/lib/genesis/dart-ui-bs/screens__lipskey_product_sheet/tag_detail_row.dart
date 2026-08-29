// 🧼 אטום · TagDetailRow — שורת-פירוט עם תג-קטן: תג-גוון + כותרת + שורת-סיבה.
// מוצא: screens__lipskey_product_sheet.dart:2619-2666 (_kitRow — כלי/איטום/בטיחות)
// + 2720-2760 (שורת-תקינות עם תג-חובה) — דדופ פנים-מסך: אותו מנגנון; ההבדלים
// (משקל-כותרת w600/w700 · משקל-תג w700/w800 · height של הסיבה) ⇒ params.
// תוויות-התג (kitTagLabels/mustBadge ב-content) והטקסטים מוזרקים מהקופסה.
import 'package:flutter/material.dart';

class TagDetailRow extends StatelessWidget {
  const TagDetailRow({
    required this.tagLabel,
    required this.tagColor,
    required this.title,
    required this.reason,
    required this.inkColor,
    required this.reasonColor,
    this.tagFgColor,
    this.titleWeight = FontWeight.w600,
    this.tagWeight = FontWeight.w700,
    this.reasonHeight,
    this.centerTag = false,
    super.key,
  });
  final String tagLabel, title, reason;

  /// tagColor = גוון-התג (רקע באלפא 0.18); tagFgColor = צבע-טקסט-התג (ברירת-מחדל: tagColor).
  final Color tagColor;
  final Color? tagFgColor;
  final Color inkColor, reasonColor;
  final FontWeight titleWeight, tagWeight;
  final double? reasonHeight;

  /// false = crossAxisAlignment.start (כמקור בשתי השורות).
  final bool centerTag;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
        child: Row(
          crossAxisAlignment:
              centerTag ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: tagColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(tagLabel,
                  style: TextStyle(
                      color: tagFgColor ?? tagColor,
                      fontSize: 9,
                      fontWeight: tagWeight)),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: inkColor,
                          fontSize: 12,
                          fontWeight: titleWeight)),
                  Text(reason,
                      style: TextStyle(
                          color: reasonColor,
                          fontSize: 10,
                          height: reasonHeight)),
                ],
              ),
            ),
          ],
        ),
      );
}
