// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__lipskey_brand_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/brand_header.dart';
import '../dart-ui-bs/auto/lipskey_brand_section_card.dart';
import '../dart-data-bs/auto/screens__lipskey_brand_screen_content.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class LipskeyBrandScreenTokens {
  const LipskeyBrandScreenTokens();

}

class LipskeyBrandScreenComposed extends StatelessWidget {
  const LipskeyBrandScreenComposed({required this.onTap, required this.catCount, required this.emoji, required this.name, required this.prodCount, required this.totalCats, required this.totalProducts, required this.t, super.key});

  final VoidCallback onTap;
  final int catCount;
  final String emoji;
  final String name;
  final int prodCount;
  final int totalCats;
  final int totalProducts;
  final LipskeyBrandScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          BrandHeader(
            fallback: brand_header_fallback,
            label: brand_header_label,
            label2: brand_header_label2,
            totalProducts: totalProducts,
            totalCats: totalCats,
          ),
          LipskeyBrandSectionCard(
            label: lipskey_brand_section_card_label,
            label2: lipskey_brand_section_card_label2,
            emoji: emoji,
            name: name,
            prodCount: prodCount,
            catCount: catCount,
            onTap: onTap,
          ),
        ],
      );
}
