// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__trade_builder__connection_rule_studio.dart (בנייה-חכמה main) · מחווט: 3 · TODO: 6.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/trade_builder/connection_rule_studio.dart';
import 'package:buildsmart/domain/connection_resolver.dart';
import 'package:buildsmart/domain/connection_schema.dart';
import 'package:buildsmart/state/trades_store.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import '../dart-screens-bs/trade_builder_connection_rule_studio.g.dart';

class TradeBuilderConnectionRuleStudioBoard extends ConsumerWidget {
  const TradeBuilderConnectionRuleStudioBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TradeBuilderConnectionRuleStudioComposed(
      onDelete: () {} /* TODO-לוח */,
      onPressed: () => Navigator.pop(context, true),
      onPressed2: () => Navigator.pop(context, false),
      onTap: () {} /* TODO-לוח */,
      enabled: false /* TODO-לוח: bool */,
      label: '' /* TODO-לוח: String */,
      methodLabelHe: '' /* TODO-לוח: String */,
      nameHe: '' /* TODO-לוח: String */,
      title: 'מחברים',
      t: TradeBuilderConnectionRuleStudioTokens(),
    );
  }
}
