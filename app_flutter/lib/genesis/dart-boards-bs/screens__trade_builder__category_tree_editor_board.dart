// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__trade_builder__category_tree_editor.dart (בנייה-חכמה main) · מחווט: 6 · TODO: 1.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/screens/trade_builder/attribute_schema_editor.dart';
import 'package:buildsmart/screens/trade_builder/product_authoring_screen.dart';
import 'package:buildsmart/state/trades_store.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import '../dart-screens-bs/trade_builder_category_tree_editor.g.dart';

class TradeBuilderCategoryTreeEditorBoard extends ConsumerWidget {
  const TradeBuilderCategoryTreeEditorBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TradeBuilderCategoryTreeEditorComposed(
      onDelete: c.onDelete,
      onTap: c.onTap,
      emoji: c.emoji,
      enabled: _name.text.trim().isNotEmpty,
      fallback: '' /* TODO-לוח: String */,
      label: _add.label,
      titleHe: c.titleHe,
      t: TradeBuilderCategoryTreeEditorTokens(),
    );
  }
}
