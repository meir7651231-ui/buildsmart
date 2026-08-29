// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: screens__trade_builder__trade_define_step.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/save_draft_button.dart';
import '../dart-ui-bs/auto/trade_builder_trade_define_step_color_swatch.dart';
import '../dart-data-bs/auto/screens__trade_builder__trade_define_step_content.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class TradeBuilderTradeDefineStepTokens {
  const TradeBuilderTradeDefineStepTokens();

}

class TradeBuilderTradeDefineStepComposed extends StatelessWidget {
  const TradeBuilderTradeDefineStepComposed({required this.onTap, required this.color, required this.enabled, required this.index, required this.selected, required this.t, super.key});

  final VoidCallback onTap;
  final int color;
  final bool enabled;
  final int index;
  final bool selected;
  final TradeBuilderTradeDefineStepTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          TradeBuilderTradeDefineStepColorSwatch(
            label: trade_builder_trade_define_step_color_swatch_label,
            color: color,
            index: index,
            selected: selected,
            onTap: onTap,
          ),
          SaveDraftButton(
            label: save_draft_button_label,
            fallback: save_draft_button_fallback,
            enabled: enabled,
            onTap: onTap,
          ),
        ],
      );
}
