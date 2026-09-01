// 🧼 אטום · AccessoryRow — שורת-אביזר: גליף + שם (+תג-חובה אופציונלי).
// מוצא: screens__lipskey_product_sheet.dart:2668-2701 (_accRow).
// תג-החובה (t_116f6cc8 · cfg: lipskey_product_sheet.must_badge) מוזרק כ-badgeLabel;
// null = בלי תג (אביזר-אופציונלי). צבעי-התג (0xFFFF6B35 / 0xFFCC4A14 במקור) = פיגמנטים.
import 'package:flutter/material.dart';

class AccessoryRow extends StatelessWidget {
  const AccessoryRow({
    required this.emoji,
    required this.name,
    required this.inkColor,
    this.badgeLabel,
    this.badgeBgColor,
    this.badgeFgColor,
    super.key,
  });
  final String emoji, name;
  final Color inkColor;
  final String? badgeLabel;
  final Color? badgeBgColor, badgeFgColor;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: inkColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
            if (badgeLabel != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(badgeLabel!,
                    style: TextStyle(
                        color: badgeFgColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w700)),
              ),
          ],
        ),
      );
}
