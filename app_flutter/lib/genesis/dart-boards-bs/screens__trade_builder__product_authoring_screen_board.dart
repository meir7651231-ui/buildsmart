// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__trade_builder__product_authoring_screen.dart (בנייה-חכמה main) · מחווט: 1 · TODO: 7.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/trade_builder/product_authoring_screen.dart';
import 'package:buildsmart/domain/trade_import.dart';
import 'package:buildsmart/domain/trade_schema.dart';
import 'package:buildsmart/screens/trade_builder/accessory_rule_editor.dart';
import 'package:buildsmart/screens/trade_builder/connection_rule_studio.dart';
import 'package:buildsmart/state/trades_store.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import '../dart-screens-bs/trade_builder_product_authoring_screen.g.dart';

class TradeBuilderProductAuthoringScreenBoard extends ConsumerWidget {
  const TradeBuilderProductAuthoringScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TradeBuilderProductAuthoringScreenComposed(
      onDelete: () {} /* TODO-לוח */,
      onTap: () {} /* TODO-לוח */,
      categoryTitle: '' /* TODO-לוח: String */,
      enabled: false /* TODO-לוח: bool */,
      id: '' /* TODO-לוח: String */,
      label: '' /* TODO-לוח: String */,
      nameHe: '' /* TODO-לוח: String */,
      title: 'ייבוא מ-CSV',
      t: TradeBuilderProductAuthoringScreenTokens(),
    );
  }
}
