// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__courier_certs_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/preset_chip.dart';

/// שורת-נתונים לסקציית-repeat — הלוח ממפה את הרשימה-החיה לפריטים.
class PresetChipItem {
  const PresetChipItem({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;
}

/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class CourierCertsScreenTokens {
  const CourierCertsScreenTokens();

}

class CourierCertsScreenComposed extends StatelessWidget {
  const CourierCertsScreenComposed({required this.presetChipItems, required this.t, super.key});


  final List<PresetChipItem> presetChipItems;
  final CourierCertsScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          for (final p in presetChipItems) ...[
          PresetChip(
            label: p.label,
            selected: p.selected,
            onTap: p.onTap,
          ),
          const SizedBox(height: 8),
        ],
        ],
      );
}
