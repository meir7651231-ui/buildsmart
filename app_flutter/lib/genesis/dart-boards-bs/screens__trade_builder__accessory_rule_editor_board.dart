// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__trade_builder__accessory_rule_editor.dart (בנייה-חכמה main) · מחווט: 0 · TODO: 9.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/trade_builder/accessory_rule_editor.dart';
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
      onDelete: () {} /* TODO-לוח */,
      onTap: () {} /* TODO-לוח */,
      emoji: '' /* TODO-לוח: String */,
      enabled: false /* TODO-לוח: bool */,
      mustHave: false /* TODO-לוח: bool */,
      nameHe: '' /* TODO-לוח: String */,
      price: null /* TODO-לוח: int? */,
      price2: 0 /* TODO-לוח: int */,
      whyHe: '' /* TODO-לוח: String */,
      t: TradeBuilderAccessoryRuleEditorTokens(),
    );
  }
}
