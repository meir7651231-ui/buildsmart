// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__trade_builder__attribute_schema_editor.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/match_chip.dart';
import '../dart-ui-bs/auto/trade_builder_accessory_rule_editor_pill_button.dart';
import '../dart-ui-bs/auto/value_chip.dart';
import '../dart-ui-bs/auto/warn_chip.dart';

/// שורת-נתונים לסקציית-repeat — הלוח ממפה את הרשימה-החיה לפריטים.
class MatchChipItem {
  const MatchChipItem({required this.text});
  final String text;
}

/// שורת-נתונים לסקציית-repeat — הלוח ממפה את הרשימה-החיה לפריטים.
class ValueChipItem {
  const ValueChipItem({required this.text});
  final String text;
}

/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class TradeBuilderAttributeSchemaEditorTokens {
  const TradeBuilderAttributeSchemaEditorTokens();

}

class TradeBuilderAttributeSchemaEditorComposed extends StatelessWidget {
  const TradeBuilderAttributeSchemaEditorComposed({required this.onTap,VoidCallback, required this.enabled, required this.label, required this.matchChipItems, required this.text, required this.valueChipItems, required this.t, super.key});

  final VoidCallback onTap;
  final bool enabled;
  final String label;
  final List<MatchChipItem> matchChipItems;
  final String text;
  final List<ValueChipItem> valueChipItems;
  final TradeBuilderAttributeSchemaEditorTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          TradeBuilderAccessoryRuleEditorPillButton(
            label: label,
            onTap: onTap,
            enabled: enabled,
          ),
          WarnChip(
            text: text,
          ),
          for (final m in matchChipItems) ...[
          MatchChip(
            text: m.text,
          ),
          const SizedBox(height: 8),
        ],
          for (final v in valueChipItems) ...[
          ValueChip(
            text: v.text,
          ),
          const SizedBox(height: 8),
        ],
        ],
      );
}
