// 🧼 אטום · ProductMiniCard — מיני-כרטיס-מוצר לקרוסלה אופקית: מדיה/גליף +
// שם (2 שורות) + תגית-מק"ט, ואופציונלית צ׳יפ-קישור (איך-זה-מתחבר).
// דדופ פנים-מסך: מאחד _RelatedCard (:1416 — רוחב 112, תמונה 56) עם כרטיס
// _miniCarousel (:3026 — רוחב 100, תמונה 44, צ׳יפ-קישור) — מנגנון אחד, מידות-props.
// המדיה מוזרקת כ-Widget (הקופסה בונה productImage עם fallback-גליף) — האטום עיוור לנכס.
import 'package:flutter/material.dart';

class ProductMiniCard extends StatelessWidget {
  const ProductMiniCard({
    required this.media,
    required this.title,
    required this.skuLabel,
    required this.onTap,
    required this.surfaceColor,
    required this.borderColor,
    required this.inkColor,
    required this.mutedColor,
    this.width = 112,
    this.mediaHeight = 56,
    this.radius = 13,
    this.padding = 9,
    this.titleFontSize = 11,
    this.titleLineHeight = 1.25,
    this.skuFontSize = 9,
    this.mediaGap = 5,
    this.linkChipLabel,
    this.linkChipBg,
    this.linkChipFg,
    this.titleExpanded = false,
    this.skuGap = 3,
    super.key,
  });

  final Widget media;
  final String title, skuLabel;
  final VoidCallback onTap;
  final Color surfaceColor, borderColor, inkColor, mutedColor;
  final double width, mediaHeight, radius, padding, titleFontSize, titleLineHeight, skuFontSize, mediaGap;

  /// Optional connection-explain chip under the title (compat carousel).
  final String? linkChipLabel;
  final Color? linkChipBg, linkChipFg;

  /// נאמנות-מקור: פריט-הקרוסלה (:3065) עוטף את השם ב-Expanded (דוחף את המק"ט
  /// לתחתית); כרטיס-related (:1449) ב-Flexible. skuGap: 3 בכרטיס-related (:1456),
  /// 0 בפריט-קרוסלה בלי-צ'יפ (אין SizedBox לפני המק"ט במקור).
  final bool titleExpanded;
  final double skuGap;

  @override
  Widget build(BuildContext context) {
    final chip = linkChipLabel;
    final titleText = Text(title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            color: inkColor,
            fontSize: titleFontSize,
            height: titleLineHeight));
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: surfaceColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: mediaHeight, child: media),
            SizedBox(height: mediaGap),
            if (titleExpanded)
              Expanded(child: titleText)
            else
              Flexible(child: titleText),
            if (chip != null && chip.isNotEmpty) ...[
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: linkChipBg,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(chip,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: linkChipFg,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 2),
            ] else if (skuGap > 0)
              SizedBox(height: skuGap),
            Text(skuLabel,
                style: TextStyle(
                    color: mutedColor,
                    fontSize: skuFontSize,
                    fontFamily: 'monospace')),
          ],
        ),
      ),
    );
  }
}
