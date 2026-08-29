// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__trade_builder__accessory_rule_editor.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/accessory_tile.dart';
import '../dart-ui-bs/auto/empty_accessories.dart';
import '../dart-ui-bs/auto/must_chip.dart';
import '../dart-ui-bs/auto/price_chip.dart';
import '../dart-ui-bs/auto/trade_builder_accessory_rule_editor_pill_button.dart';
import '../dart-data-bs/auto/screens__trade_builder__accessory_rule_editor_content.dart';
import '../dart-data-bs/auto/screens__trade_builder__accessory_rule_editor_content2.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class TradeBuilderAccessoryRuleEditorTokens {
  const TradeBuilderAccessoryRuleEditorTokens();

}

class TradeBuilderAccessoryRuleEditorComposed extends StatelessWidget {
  const TradeBuilderAccessoryRuleEditorComposed({required this.onDelete, required this.onTap, required this.emoji, required this.enabled, required this.mustHave, required this.nameHe, required this.price, required this.price2, required this.whyHe, required this.t, super.key});

  final VoidCallback onDelete;
  final VoidCallback onTap;
  final String emoji;
  final bool enabled;
  final bool mustHave;
  final String nameHe;
  final int? price;
  final int price2;
  final String whyHe;
  final TradeBuilderAccessoryRuleEditorTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          EmptyAccessories(
            fallback: empty_accessories_fallback,
          ),
          AccessoryTile(
            label: accessory_tile_label,
            tooltip: accessory_tile_tooltip,
            price: price,
            mustHave: mustHave,
            emoji: emoji,
            nameHe: nameHe,
            whyHe: whyHe,
            fallback: accessory_tile_fallback,
            onDelete: onDelete,
          ),
          TradeBuilderAccessoryRuleEditorPillButton(
            label: trade_builder_accessory_rule_editor_pill_button_label,
            onTap: onTap,
            enabled: enabled,
          ),
          MustChip(
            fallback: must_chip_fallback,
          ),
          PriceChip(
            price: price2,
          ),
        ],
      );
}
