// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__worker_equipment_checklist_sheet.dart (בנייה-חכמה main) · מחווט: 2 · TODO: 1.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/worker_equipment_checklist_sheet.dart';
import 'package:buildsmart/data/task_skus_local.dart';
import 'package:buildsmart/logic/equipment_stock_join.dart';
import 'package:buildsmart/logic/install_kit.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/employer_stock.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import '../dart-screens-bs/worker_equipment_checklist_sheet.g.dart';

class WorkerEquipmentChecklistSheetBoard extends ConsumerStatefulWidget {
  const WorkerEquipmentChecklistSheetBoard({super.key});

  @override
  ConsumerState<WorkerEquipmentChecklistSheetBoard> createState() => _WorkerEquipmentChecklistSheetBoardState();
}

class _WorkerEquipmentChecklistSheetBoardState extends ConsumerState<WorkerEquipmentChecklistSheetBoard> {
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    return WorkerEquipmentChecklistSheetComposed(
      onTap: () {} /* TODO-לוח */,
      label: _sent ? '✓ נשלח לקבלן' : 'שלח רשימה לקבלן',
      text: 'צ׳קליסט ציוד',
      t: WorkerEquipmentChecklistSheetTokens(),
    );
  }
}
