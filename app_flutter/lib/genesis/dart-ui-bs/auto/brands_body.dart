// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__manager_dashboard_screen:_BrandsBody (בנייה-חכמה main) · צרור-1 · props-שורש: label, label2
// התוכן: new/dart-data-bs/auto/screens__manager_dashboard_screen_content.dart
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class BrandsBody extends StatelessWidget {
  BrandsBody({required this.label, required this.label2});
  final String label;
  final String label2;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${label}${kBrands.length})',
          style: const TextStyle(
            color: BsTokens.inkLight,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: BsTokens.space2),
        for (final b in kBrands)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: BsTokens.space2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.name,
                        style: const TextStyle(
                          color: BsTokens.inkLight,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (b.tagline.isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Text(
                          b.tagline,
                          style: const TextStyle(
                            color: BsTokens.mutedLight,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (b.productCount > 0) ...[
                  const SizedBox(width: BsTokens.space2),
                  Text(
                    '${b.productCount}${label2}',
                    style: const TextStyle(
                      color: BsTokens.mutedLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
