// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__trade_builder__attribute_schema_editor.dart (בנייה-חכמה main) · מחווט: 5 · TODO: 1.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/state/trades_store.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import '../dart-screens-bs/trade_builder_attribute_schema_editor.g.dart';

class TradeBuilderAttributeSchemaEditorBoard extends ConsumerWidget {
  const TradeBuilderAttributeSchemaEditorBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TradeBuilderAttributeSchemaEditorComposed(
      onTap: _addValue,
      enabled: _value.text.trim().isNotEmpty,
      label: _addValue.label,
      matchChipItems: matches.map((m) => MatchChipItem(text: '${m.$1}: ${m.$2}')).toList(),
      text: '' /* TODO-לוח: String */,
      valueChipItems: def.values.map((v) => ValueChipItem(text: v.labelHe)).toList(),
      t: TradeBuilderAttributeSchemaEditorTokens(),
    );
  }
}
