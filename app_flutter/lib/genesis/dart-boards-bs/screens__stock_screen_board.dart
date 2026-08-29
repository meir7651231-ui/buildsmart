// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__stock_screen.dart (בנייה-חכמה main) · מחווט: 0 · TODO: 7.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/stock_screen.dart';
import 'package:buildsmart/data/phaseb_seeds.dart';
import 'package:buildsmart/data/repositories/stock_firebase.dart';
import 'package:buildsmart/data/repositories/stock_local.dart';
import 'package:buildsmart/screens/contractor_material_requests_sheet.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/toast.dart';
import '../dart-screens-bs/stock_screen.g.dart';

class StockScreenBoard extends ConsumerWidget {
  const StockScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StockScreenComposed(
      onMove: () {} /* TODO-לוח */,
      onTap: () {} /* TODO-לוח */,
      info: (null as dynamic) /* TODO-לוח: ({String img, String why}) */,
      label: '' /* TODO-לוח: String */,
      name: '' /* TODO-לוח: String */,
      on: false /* TODO-לוח: bool */,
      warehouse: false /* TODO-לוח: bool */,
      t: StockScreenTokens(),
    );
  }
}
