// 🧼 אטום · BrandListRow — שורת-מותג: emoji, שם, תת-שורה, ותווית-ספירה.
// מוצא: לולאת-המותגים של _BrandsBody (kBrands ⇒ הקופסה מזרימה פר-מותג;
// countLabel מפורמט בקופסה מ-brandsBodyContent.countTpl; ריק ⇒ לא מרכיבים).
import 'package:flutter/material.dart';

class BrandListRow extends StatelessWidget {
  const BrandListRow({
    required this.emoji, required this.name, required this.inkColor,
    required this.mutedColor, required this.gap,
    this.tagline = '', this.countLabel = '', super.key,
  });

  final String emoji, name, tagline, countLabel;
  final Color inkColor, mutedColor;

  /// BsTokens.space2 במקור.
  final double gap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            SizedBox(width: gap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: inkColor,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (tagline.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(
                      tagline,
                      style: TextStyle(color: mutedColor, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            if (countLabel.isNotEmpty) ...[
              SizedBox(width: gap),
              Text(
                countLabel,
                style: TextStyle(
                  color: mutedColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      );
}
