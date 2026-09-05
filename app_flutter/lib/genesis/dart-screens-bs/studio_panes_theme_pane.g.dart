// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__studio__panes__theme_pane.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/contrast_warning.dart';
import '../dart-ui-bs/auto/label.dart';
import '../dart-ui-bs/auto/swatch.dart';
import '../dart-data-bs/auto/screens__studio__panes__theme_pane_content.dart';

/// שורת-נתונים לסקציית-repeat — הלוח ממפה את הרשימה-החיה לפריטים.
class SwatchItem {
  const SwatchItem({required this.color, required this.selected, required this.onTap});
  final Color color;
  final bool selected;
  final VoidCallback onTap;
}

/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class StudioPanesThemePaneTokens {
  const StudioPanesThemePaneTokens();

}

class StudioPanesThemePaneComposed extends StatelessWidget {
  const StudioPanesThemePaneComposed({required this.ratio, required this.swatchItems, required this.text, required this.t, super.key});


  final double ratio;
  final List<SwatchItem> swatchItems;
  final String text;
  final StudioPanesThemePaneTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          Label(
            text,
          ),
          for (final c in swatchItems) ...[
          Swatch(
            label: swatch_label,
            color: c.color,
            selected: c.selected,
            onTap: c.onTap,
          ),
          const SizedBox(height: 8),
        ],
          ContrastWarning(
            label: contrast_warning_label,
            label2: contrast_warning_label2,
            ratio: ratio,
          ),
        ],
      );
}
