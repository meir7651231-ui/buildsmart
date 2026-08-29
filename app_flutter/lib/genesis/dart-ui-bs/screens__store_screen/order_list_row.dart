// 🧼 אטום · OrderListRow — שורת-הזמנה: גליף-בעיגול, מזהה+זמן, מטא + תג-שלב.
// שונה מ-OrderCard שבמדף (שם כרטיס-רוחב בלי גליף/תג). מוצא:
// screens__store_screen.dart:3951 (_OrderRow). התרת-סבך: פתיחת ה-sheet
// (showModalBottomSheet + _OrderSheet) = קופסה ⇒ onTap; התוויות מפורמטות בקופסה
// (idLabel · timeLabel · metaLabel = פריטים·סה״כ, orderItemsCountTpl ב-content);
// תג-השלב = slot (stage_chip מחווט-קופסה — חוק-1).
import 'package:flutter/material.dart';

class OrderListRow extends StatelessWidget {
  const OrderListRow({
    required this.glyph, required this.idLabel, required this.timeLabel,
    required this.metaLabel, required this.stageChip, required this.onTap,
    required this.circleColor, required this.inkColor, required this.mutedColor,
    super.key,
  });
  final String glyph, idLabel, timeLabel, metaLabel;
  final Widget stageChip;
  final VoidCallback onTap;
  final Color circleColor, inkColor, mutedColor;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(glyph, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            idLabel,
                            style: TextStyle(
                              color: inkColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(timeLabel, style: TextStyle(color: mutedColor, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            metaLabel,
                            style: TextStyle(color: mutedColor, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        stageChip,
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
