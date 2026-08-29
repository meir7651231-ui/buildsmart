// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__suppliers_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/supplier_tile.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class SuppliersScreenTokens {
  const SuppliersScreenTokens();

}

class SuppliersScreenComposed extends StatelessWidget {
  const SuppliersScreenComposed({required this.onTap,VoidCallback, required this.emoji, required this.subtitle, required this.title, required this.t, super.key});

  final VoidCallback onTap;
  final String emoji;
  final String subtitle;
  final String title;
  final SuppliersScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          SupplierTile(
            emoji: emoji,
            title: title,
            subtitle: subtitle,
            onTap: onTap,
          ),
        ],
      );
}
