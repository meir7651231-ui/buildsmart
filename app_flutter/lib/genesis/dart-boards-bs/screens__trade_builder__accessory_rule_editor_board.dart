// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__trade_builder__accessory_rule_editor.dart (בנייה-חכמה main) · מחווט: 9 · TODO: 1.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/state/trades_store.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import '../dart-screens-bs/trade_builder_accessory_rule_editor.g.dart';

class TradeBuilderAccessoryRuleEditorBoard extends ConsumerWidget {
  const TradeBuilderAccessoryRuleEditorBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TradeBuilderAccessoryRuleEditorComposed(
      onDelete: r.onDelete,
      onTap: _add,
      emoji: r.emoji,
      enabled: _name.text.trim().isNotEmpty && catValue != null,
      label: _add.label,
      mustHave: r.mustHave,
      nameHe: r.nameHe,
      price: r.price,
      price2: 0 /* TODO-לוח: int */,
      whyHe: r.whyHe,
      t: TradeBuilderAccessoryRuleEditorTokens(),
    );
  }
}
