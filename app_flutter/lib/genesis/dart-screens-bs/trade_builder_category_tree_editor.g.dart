// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__trade_builder__category_tree_editor.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/category_tile.dart';
import '../dart-ui-bs/auto/empty_accessories.dart';
import '../dart-ui-bs/auto/trade_builder_accessory_rule_editor_pill_button.dart';
import '../dart-data-bs/auto/screens__trade_builder__category_tree_editor_content.dart';
import '../dart-data-bs/auto/screens__trade_builder__category_tree_editor_content2.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class TradeBuilderCategoryTreeEditorTokens {
  const TradeBuilderCategoryTreeEditorTokens();

}

class TradeBuilderCategoryTreeEditorComposed extends StatelessWidget {
  const TradeBuilderCategoryTreeEditorComposed({required this.onDelete, required this.onTap, required this.emoji, required this.enabled, required this.fallback, required this.titleHe, required this.t, super.key});

  final VoidCallback onDelete;
  final VoidCallback onTap;
  final String emoji;
  final bool enabled;
  final String fallback;
  final String titleHe;
  final TradeBuilderCategoryTreeEditorTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          EmptyAccessories(
            fallback: fallback,
          ),
          CategoryTile(
            label: category_tile_label,
            tooltip: category_tile_tooltip,
            emoji: emoji,
            titleHe: titleHe,
            onTap: onTap,
            onDelete: onDelete,
          ),
          TradeBuilderAccessoryRuleEditorPillButton(
            label: trade_builder_accessory_rule_editor_pill_button_label,
            onTap: onTap,
            enabled: enabled,
          ),
        ],
      );
}
