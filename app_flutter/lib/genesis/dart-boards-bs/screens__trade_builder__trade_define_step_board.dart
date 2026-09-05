// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__trade_builder__trade_define_step.dart (בנייה-חכמה main) · מחווט: 1 · TODO: 4.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/trade_builder/trade_define_step.dart';
import 'package:buildsmart/data/personas.dart';
import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/state/trades_store.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import '../dart-screens-bs/trade_builder_trade_define_step.g.dart';

class TradeBuilderTradeDefineStepBoard extends ConsumerStatefulWidget {
  const TradeBuilderTradeDefineStepBoard({super.key});

  @override
  ConsumerState<TradeBuilderTradeDefineStepBoard> createState() => _TradeBuilderTradeDefineStepBoardState();
}

class _TradeBuilderTradeDefineStepBoardState extends ConsumerState<TradeBuilderTradeDefineStepBoard> {
  final _name = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final valid = _name.text.trim().isNotEmpty;
    return TradeBuilderTradeDefineStepComposed(
      onTap: () {} /* TODO-לוח */,
      color: 0 /* TODO-לוח: int */,
      enabled: valid,
      index: 0 /* TODO-לוח: int */,
      selected: false /* TODO-לוח: bool */,
      t: TradeBuilderTradeDefineStepTokens(),
    );
  }
}
