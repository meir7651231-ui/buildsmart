// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__trade_builder__trade_define_step.dart (בנייה-חכמה main) · מחווט: 5 · TODO: 0.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/data/personas.dart';
import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/state/trades_store.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import '../dart-screens-bs/trade_builder_trade_define_step.g.dart';

class TradeBuilderTradeDefineStepBoard extends ConsumerWidget {
  const TradeBuilderTradeDefineStepBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TradeBuilderTradeDefineStepComposed(
      onTap: _saveDraft,
      color: _kTradeColors[i],
      enabled: valid,
      index: i,
      selected: _color == _kTradeColors[i],
      t: TradeBuilderTradeDefineStepTokens(),
    );
  }
}
