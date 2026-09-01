// 🧼 אטום · ActionChipRail — מסילת-צ'יפים: כותרת קטנה + Wrap של ActionChips נלחצים.
// מוצא: screens__lipskey_product_sheet.dart:416-463 (_hopRail · t_00644600) + 468-513
// (_hopConnectRail · t_b1107d71) — דדופ פנים-מסך: אותו מנגנון; ההבדל = כותרת + רשימת-
// השכנים (HopGraph = מנוע-מחצבה, מחושב בקופסה). התרת-סבך: divePoolBySku/HopGraph ⇒
// chipLabels + onChipTap(index); שער-הדגל (_live) = חיווט-קופסה.
import 'package:flutter/material.dart';

class ActionChipRail extends StatelessWidget {
  const ActionChipRail({
    required this.title,
    required this.chipLabels,
    required this.onChipTap,
    this.maxChipWidth = 160,
    super.key,
  });
  final String title;
  final List<String> chipLabels;
  final void Function(int index) onChipTap;
  final double maxChipWidth;

  @override
  Widget build(BuildContext context) {
    if (chipLabels.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var i = 0; i < chipLabels.length; i++)
                ActionChip(
                  label: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxChipWidth),
                    child: Text(chipLabels[i],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12)),
                  ),
                  onPressed: () => onChipTap(i),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
