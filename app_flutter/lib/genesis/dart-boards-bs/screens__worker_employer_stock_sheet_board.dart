// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__worker_employer_stock_sheet.dart (בנייה-חכמה main) · מחווט: 7 · TODO: 0.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      onSend: _itemsCtrl.onSend,
      onToggle: _itemsCtrl.onToggle,
      composing: _composing,
      itemsCtrl: _itemsCtrl,
      location: it.location,
      name: it.name,
      noteCtrl: _noteCtrl,
      t: WorkerEmployerStockSheetTokens(),
    );
  }
}
