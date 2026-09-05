// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__suppliers_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/supplier_tile.dart';
import '../dart-data-bs/auto/screens__suppliers_screen_content2.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class SuppliersScreenTokens {
  const SuppliersScreenTokens();

}

class SuppliersScreenComposed extends StatelessWidget {
  const SuppliersScreenComposed({required this.onTap, required this.subtitle, required this.t, super.key});

  final VoidCallback onTap;
  final String subtitle;
  final SuppliersScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          SupplierTile(
            emoji: supplier_tile_emoji,
            title: supplier_tile_title,
            subtitle: subtitle,
            onTap: onTap,
          ),
        ],
      );
}
