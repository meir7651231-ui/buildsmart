// 🧼 אטום · RecommendedKitBanner — באנר-ערכה: גליף + כותרת/תת-כותרת + כפתור-פעולה.
// מוצא: screens__lipskey_product_sheet.dart:1055-1106 (כרטיס ערכת-ההתקנה-המומלצת).
// הכותרת (t_4c529070 · cfg: recommended_kit), תת-הכותרת (תבנית kitPartsPerSideTpl)
// ותווית-הכפתור (t_846e081f · cfg: add_kit) מוזרמות מ-content; _addKitToCart ⇒ onPressed.
import 'package:flutter/material.dart';

class RecommendedKitBanner extends StatelessWidget {
  const RecommendedKitBanner({
    required this.leadingEmoji,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onPressed,
    required this.tintBgColor,
    required this.tintBorderColor,
    required this.buttonBgColor,
    required this.buttonFgColor,
    required this.titleColor,
    required this.subtitleColor,
    super.key,
  });
  final String leadingEmoji, title, subtitle, buttonLabel;
  final VoidCallback onPressed;
  final Color tintBgColor, tintBorderColor, buttonBgColor, buttonFgColor,
      titleColor, subtitleColor;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: tintBgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tintBorderColor),
        ),
        child: Row(
          children: [
            Text(leadingEmoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: titleColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                  Text(subtitle,
                      style: TextStyle(color: subtitleColor, fontSize: 11)),
                ],
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: buttonBgColor,
                foregroundColor: buttonFgColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              onPressed: onPressed,
              child: Text(buttonLabel,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 13)),
            ),
          ],
        ),
      );
}
