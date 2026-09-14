// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__trade_builder__trade_publish_sheet.dart (בנייה-חכמה main) · מחווט: 0 · TODO: 3.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/trade_builder/trade_publish_sheet.dart';
import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/state/trades_store.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import '../dart-screens-bs/trade_builder_trade_publish_sheet.g.dart';

class TradeBuilderTradePublishSheetBoard extends ConsumerWidget {
  const TradeBuilderTradePublishSheetBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TradeBuilderTradePublishSheetComposed(
      onTap: () {} /* TODO-לוח */,
      enabled: false /* TODO-לוח: bool */,
      pass: false /* TODO-לוח: bool */,
      t: TradeBuilderTradePublishSheetTokens(),
    );
  }
}
