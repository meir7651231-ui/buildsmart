// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__trade_builder__category_tree_editor.dart (בנייה-חכמה main) · מחווט: 1 · TODO: 5.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/trade_builder/category_tree_editor.dart';
import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/screens/trade_builder/attribute_schema_editor.dart';
import 'package:buildsmart/screens/trade_builder/product_authoring_screen.dart';
import 'package:buildsmart/state/trades_store.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import '../dart-screens-bs/trade_builder_category_tree_editor.g.dart';

class TradeBuilderCategoryTreeEditorBoard extends ConsumerStatefulWidget {
  const TradeBuilderCategoryTreeEditorBoard({super.key});

  @override
  ConsumerState<TradeBuilderCategoryTreeEditorBoard> createState() => _TradeBuilderCategoryTreeEditorBoardState();
}

class _TradeBuilderCategoryTreeEditorBoardState extends ConsumerState<TradeBuilderCategoryTreeEditorBoard> {
  final _name = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TradeBuilderCategoryTreeEditorComposed(
      onDelete: () {} /* TODO-לוח */,
      onTap: () {} /* TODO-לוח */,
      emoji: '' /* TODO-לוח: String */,
      enabled: _name.text.trim().isNotEmpty,
      fallback: '' /* TODO-לוח: String */,
      titleHe: '' /* TODO-לוח: String */,
      t: TradeBuilderCategoryTreeEditorTokens(),
    );
  }
}
