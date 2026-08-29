// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__store_profile_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/sstat.dart';

/// שורת-נתונים לסקציית-repeat — הלוח ממפה את הרשימה-החיה לפריטים.
class SStatItem {
  const SStatItem({required this.value, required this.label});
  final String value;
  final String label;
}

/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class StoreProfileScreenTokens {
  const StoreProfileScreenTokens();

}

class StoreProfileScreenComposed extends StatelessWidget {
  const StoreProfileScreenComposed({required this.sStatItems, required this.t, super.key});


  final List<SStatItem> sStatItems;
  final StoreProfileScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          for (final s in sStatItems) ...[
          SStat(
            value: s.value,
            label: s.label,
          ),
          const SizedBox(height: 8),
        ],
        ],
      );
}
