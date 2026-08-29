// 🧼 אטום · StoreHubRow — שורת-האב: גליף-בעיגול (+לב-מועדף), כותרת+זמן, תקציר+badge.
// מוצא: screens__store_screen.dart:1460 (_StoreRow). טוסט-בבנייה (t_5de6454b) עבר
// לקופסה ⇒ onTap חובה. badgeLabel מפורמט בקופסה (null = בלי badge; גם צובע את הזמן).
import 'package:flutter/material.dart';

class StoreHubRow extends StatelessWidget {
  const StoreHubRow({
    required this.emoji, required this.title, required this.preview,
    required this.timeLabel, required this.isFav, required this.onTap,
    required this.circleColor, required this.inkColor, required this.mutedColor,
    required this.accentColor, required this.badgeInkColor, required this.favColor,
    this.badgeLabel, super.key,
  });
  final String emoji, title, preview, timeLabel;
  final String? badgeLabel;
  final bool isFav;
  final VoidCallback onTap;
  final Color circleColor, inkColor, mutedColor, accentColor, badgeInkColor, favColor;

  @override
  Widget build(BuildContext context) {
    final hasBadge = badgeLabel != null;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
                if (isFav)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Icon(Icons.favorite, color: favColor, size: 14),
                  ),
              ],
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
                          title,
                          style: TextStyle(
                            color: inkColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        timeLabel,
                        style: TextStyle(
                          color: hasBadge ? accentColor : mutedColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          preview,
                          style: TextStyle(color: mutedColor, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasBadge)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            badgeLabel!,
                            style: TextStyle(
                              color: badgeInkColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
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
}
