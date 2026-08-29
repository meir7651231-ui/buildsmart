// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__worker_employer_stock_sheet.dart (בנייה-חכמה main) · מחווט: 0 · TODO: 7.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/worker_employer_stock_sheet.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/employer_stock.dart';
import 'package:buildsmart/state/material_requests_engine.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import '../dart-screens-bs/worker_employer_stock_sheet.g.dart';

class WorkerEmployerStockSheetBoard extends ConsumerWidget {
  const WorkerEmployerStockSheetBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WorkerEmployerStockSheetComposed(
      onSend: () {} /* TODO-לוח */,
      onToggle: () {} /* TODO-לוח */,
      composing: false /* TODO-לוח: bool */,
      itemsCtrl: TextEditingController() /* TODO-לוח: TextEditingController */,
      location: '' /* TODO-לוח: String */,
      name: '' /* TODO-לוח: String */,
      noteCtrl: TextEditingController() /* TODO-לוח: TextEditingController */,
      t: WorkerEmployerStockSheetTokens(),
    );
  }
}
