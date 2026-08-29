// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__trade_builder__trade_builder_home.dart (בנייה-חכמה main) · מחווט: 0 · TODO: 2.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/trade_builder/trade_builder_home.dart';
import 'package:buildsmart/data/personas.dart';
import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/screens/trade_builder/category_tree_editor.dart';
import 'package:buildsmart/screens/trade_builder/trade_define_step.dart';
import 'package:buildsmart/screens/trade_builder/trade_publish_sheet.dart';
import 'package:buildsmart/state/trades_store.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import '../dart-screens-bs/trade_builder_trade_builder_home.g.dart';

class TradeBuilderTradeBuilderHomeBoard extends ConsumerWidget {
  const TradeBuilderTradeBuilderHomeBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TradeBuilderTradeBuilderHomeComposed(
      onTap: () {} /* TODO-לוח */,
      fallback: '' /* TODO-לוח: String */,
      t: TradeBuilderTradeBuilderHomeTokens(),
    );
  }
}
