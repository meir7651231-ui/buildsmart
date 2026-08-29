// 🧼 אטום · OutlinedCardSection — כרטיס-מסגרת לבן עם כותרת + ילדים.
// איחד את שלד _AttentionCard (typeSubhead w700, padding space3) ואת שלד
// _OrderPipeline (16 w800 ink, padding space4) — טיפוגרפיה/ריפוד כ-params.
// התרת-סבך: attentionItemsProvider ריק ⇒ הקופסה פשוט לא מרכיבה את הכרטיס.
import 'package:flutter/material.dart';

class OutlinedCardSection extends StatelessWidget {
  const OutlinedCardSection({
    required this.title, required this.children,
    required this.surfaceColor, required this.borderColor, required this.radius,
    required this.padding, required this.titleColor, required this.titleSize,
    required this.titleWeight, required this.headerGap,
    this.margin, this.stretch = true, super.key,
  });

  final String title;
  final List<Widget> children;
  final Color surfaceColor, borderColor, titleColor;
  final double radius, titleSize, headerGap;
  final FontWeight titleWeight;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  /// stretch=true ⇒ CrossAxisAlignment.stretch (הכרטיס-דורש-טיפול);
  /// false ⇒ start (כרטיס-הצינור).
  final bool stretch;

  @override
  Widget build(BuildContext context) => Container(
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment:
              stretch ? CrossAxisAlignment.stretch : CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: headerGap),
              child: Text(
                title,
                style: TextStyle(
                  color: titleColor,
                  fontWeight: titleWeight,
                  fontSize: titleSize,
                ),
              ),
            ),
            ...children,
          ],
        ),
      );
}
