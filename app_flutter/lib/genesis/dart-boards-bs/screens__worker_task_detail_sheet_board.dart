// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__worker_task_detail_sheet.dart (בנייה-חכמה main) · מחווט: 1 · TODO: 1.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/worker_task_detail_sheet.dart';
import 'package:buildsmart/data/persona_data.dart';
import 'package:buildsmart/data/task_skus_local.dart';
import 'package:buildsmart/logic/install_kit.dart';
import 'package:buildsmart/screens/lipskey_product_sheet.dart';
import 'package:buildsmart/services/task_photo.dart';
import 'package:buildsmart/services/voice.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/keyboard_job_context.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:buildsmart/state/under_construction.dart';
import 'package:buildsmart/state/worker_tasks_engine.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/photo_viewer.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import '../dart-screens-bs/worker_task_detail_sheet.g.dart';

class WorkerTaskDetailSheetBoard extends ConsumerWidget {
  const WorkerTaskDetailSheetBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WorkerTaskDetailSheetComposed(
      onTap: () {} /* TODO-לוח */,
      text: 'מה להביא',
      t: WorkerTaskDetailSheetTokens(),
    );
  }
}
