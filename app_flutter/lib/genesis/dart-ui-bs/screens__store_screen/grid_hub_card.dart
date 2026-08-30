// 🧼 אטום · GridHubCard — אריח-גריד להאב-החנות: גליף + badge + כותרת + תקציר,
// עם יעד-מועדפים 48dp מונח-מעל (a11y). מוצא: screens__store_screen.dart:1300 (_GridHubCard).
// היו צרובים: tooltip-מועדפים (t_17a65674/t_4d537e46) וטוסט-בבנייה (t_5de6454b) ⇒
// favAddLabel/favRemoveLabel props + onTap חובה (הטוסט בקופסה). badgeLabel מפורמט בקופסה.
import 'package:flutter/material.dart';

class GridHubCard extends StatelessWidget {
  const GridHubCard({
    required this.emoji, required this.title, required this.preview,
    required this.isFav, required this.favAddLabel, required this.favRemoveLabel,
    required this.onFavToggle, required this.onTap,
    required this.surfaceColor, required this.borderColor,
    required this.badgeColor, required this.badgeInkColor,
    required this.inkColor, required this.mutedColor,
    required this.favActiveColor, required this.favIdleColor,
    this.badgeLabel, super.key,
  });
  final String emoji, title, preview;
  final String? badgeLabel;
  final bool isFav;
  final String favAddLabel, favRemoveLabel;
  final VoidCallback onFavToggle, onTap;
  final Color surfaceColor, borderColor, badgeColor, badgeInkColor;
  final Color inkColor, mutedColor, favActiveColor, favIdleColor;

  @override
  Widget build(BuildContext context) {
    final favLabel = isFav ? favRemoveLabel : favAddLabel;
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 22)),
                    const Spacer(),
                    if (badgeLabel != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badgeLabel!,
                          style: TextStyle(
                            color: badgeInkColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    // שומר-מקום — יעד-המועדפים האמיתי (48dp) מונח-מעל בפינה (a11y).
                    const SizedBox(width: 24, height: 24),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: TextStyle(color: inkColor, fontSize: 13, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  preview,
                  style: TextStyle(color: mutedColor, fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          PositionedDirectional(
            top: 0,
            end: 0,
            child: Tooltip(
              message: favLabel,
              child: Semantics(
                button: true,
                label: favLabel,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onFavToggle,
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? favActiveColor : favIdleColor,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
