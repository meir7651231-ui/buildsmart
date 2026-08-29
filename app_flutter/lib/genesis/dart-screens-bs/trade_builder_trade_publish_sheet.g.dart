// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__trade_builder__trade_publish_sheet.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/check_row.dart';
import '../dart-ui-bs/auto/trade_builder_accessory_rule_editor_pill_button.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class TradeBuilderTradePublishSheetTokens {
  const TradeBuilderTradePublishSheetTokens();

}

class TradeBuilderTradePublishSheetComposed extends StatelessWidget {
  const TradeBuilderTradePublishSheetComposed({required this.onTap,VoidCallback, required this.enabled, required this.label, required this.pass, required this.t, super.key});

  final VoidCallback onTap;
  final bool enabled;
  final String label;
  final bool pass;
  final TradeBuilderTradePublishSheetTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          CheckRow(
            pass: pass,
            label: label,
          ),
          TradeBuilderAccessoryRuleEditorPillButton(
            label: label,
            onTap: onTap,
            enabled: enabled,
          ),
        ],
      );
}
