// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__trade_builder__trade_builder_home.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/add_trade_button.dart';
import '../dart-ui-bs/auto/empty_accessories.dart';
import '../dart-ui-bs/auto/wizard_header.dart';
import '../dart-data-bs/auto/screens__trade_builder__trade_builder_home_content.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class TradeBuilderTradeBuilderHomeTokens {
  const TradeBuilderTradeBuilderHomeTokens();

}

class TradeBuilderTradeBuilderHomeComposed extends StatelessWidget {
  const TradeBuilderTradeBuilderHomeComposed({required this.onTap, required this.fallback, required this.t, super.key});

  final VoidCallback onTap;
  final String fallback;
  final TradeBuilderTradeBuilderHomeTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          WizardHeader(
            label: wizard_header_label,
            label2: wizard_header_label2,
            fallback: wizard_header_fallback,
            fallback2: wizard_header_fallback2,
          ),
          EmptyAccessories(
            fallback: fallback,
          ),
          AddTradeButton(
            label: add_trade_button_label,
            fallback: add_trade_button_fallback,
            onTap: onTap,
          ),
        ],
      );
}
