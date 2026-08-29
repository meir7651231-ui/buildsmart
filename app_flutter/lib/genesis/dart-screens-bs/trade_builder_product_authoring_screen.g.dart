// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__trade_builder__product_authoring_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/empty_products.dart';
import '../dart-ui-bs/auto/product_tile.dart';
import '../dart-ui-bs/auto/section_header.dart';
import '../dart-ui-bs/auto/trade_builder_accessory_rule_editor_pill_button.dart';
import '../dart-data-bs/auto/screens__trade_builder__product_authoring_screen_content.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class TradeBuilderProductAuthoringScreenTokens {
  const TradeBuilderProductAuthoringScreenTokens();

}

class TradeBuilderProductAuthoringScreenComposed extends StatelessWidget {
  const TradeBuilderProductAuthoringScreenComposed({required this.onDelete, required this.onTap, required this.categoryTitle, required this.enabled, required this.id, required this.label, required this.nameHe, required this.title, required this.t, super.key});

  final VoidCallback onDelete;
  final VoidCallback onTap;
  final String categoryTitle;
  final bool enabled;
  final String id;
  final String label;
  final String nameHe;
  final String title;
  final TradeBuilderProductAuthoringScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          EmptyProducts(
            fallback: empty_products_fallback,
          ),
          ProductTile(
            label: product_tile_label,
            tooltip: product_tile_tooltip,
            nameHe: nameHe,
            id: id,
            categoryTitle: categoryTitle,
            onDelete: onDelete,
          ),
          TradeBuilderAccessoryRuleEditorPillButton(
            label: label,
            onTap: onTap,
            enabled: enabled,
          ),
          SectionHeader(
            title: title,
          ),
        ],
      );
}
