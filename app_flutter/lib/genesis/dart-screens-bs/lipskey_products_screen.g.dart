// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__lipskey_products_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/lens_group_header.dart';
import '../dart-ui-bs/auto/store_step_btn.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class LipskeyProductsScreenTokens {
  const LipskeyProductsScreenTokens();

}

class LipskeyProductsScreenComposed extends StatelessWidget {
  const LipskeyProductsScreenComposed({required this.onTap, required this.count, required this.icon, required this.label, required this.label2, required this.message, required this.message2, required this.smartTree, required this.title, required this.t, super.key});

  final VoidCallback onTap;
  final int count;
  final IconData icon;
  final String label;
  final String label2;
  final String message;
  final String message2;
  final bool smartTree;
  final String title;
  final LipskeyProductsScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          LensGroupHeader(
            title: title,
            count: count,
            smartTree: smartTree,
          ),
          StoreStepBtn(
            message: message,
            message2: message2,
            label: label,
            label2: label2,
            icon: icon,
            onTap: onTap,
          ),
        ],
      );
}
