// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__trade_builder__attribute_schema_editor.dart (בנייה-חכמה main) · מחווט: 1 · TODO: 3.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/trade_builder/attribute_schema_editor.dart';
import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/state/trades_store.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import '../dart-screens-bs/trade_builder_attribute_schema_editor.g.dart';

class TradeBuilderAttributeSchemaEditorBoard extends ConsumerStatefulWidget {
  const TradeBuilderAttributeSchemaEditorBoard({super.key});

  @override
  ConsumerState<TradeBuilderAttributeSchemaEditorBoard> createState() => _TradeBuilderAttributeSchemaEditorBoardState();
}

class _TradeBuilderAttributeSchemaEditorBoardState extends ConsumerState<TradeBuilderAttributeSchemaEditorBoard> {
  final _value = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TradeBuilderAttributeSchemaEditorComposed(
      onTap: () {} /* TODO-לוח */,
      enabled: _value.text.trim().isNotEmpty,
      matchChipItems: const [] /* TODO-לוח: List<MatchChipItem> */,
      valueChipItems: const [] /* TODO-לוח: List<ValueChipItem> */,
      t: TradeBuilderAttributeSchemaEditorTokens(),
    );
  }
}
