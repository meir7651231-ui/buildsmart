// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__stock_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/stock_row.dart';
import '../dart-ui-bs/auto/stock_tab.dart';
import '../dart-data-bs/auto/screens__stock_screen_content.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class StockScreenTokens {
  const StockScreenTokens();

}

class StockScreenComposed extends StatelessWidget {
  const StockScreenComposed({required this.onMove, required this.onTap, required this.info, required this.label, required this.name, required this.on, required this.warehouse, required this.t, super.key});

  final VoidCallback onMove;
  final VoidCallback onTap;
  final ({String img, String why}) info;
  final String label;
  final String name;
  final bool on;
  final bool warehouse;
  final StockScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          StockTab(
            label: label,
            on: on,
            onTap: onTap,
          ),
          StockRow(
            label: stock_row_label,
            label2: stock_row_label2,
            name: name,
            info: info,
            warehouse: warehouse,
            onMove: onMove,
          ),
        ],
      );
}
