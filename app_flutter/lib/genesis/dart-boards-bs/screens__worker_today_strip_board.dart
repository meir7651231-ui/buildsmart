// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__worker_today_strip.dart (בנייה-חכמה main) · מחווט: 1 · TODO: 4.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/worker_task_detail_sheet.dart';
import 'package:buildsmart/state/smart_project_engine.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/toast.dart';
import '../dart-screens-bs/worker_today_strip.g.dart';

class WorkerTodayStripBoard extends ConsumerWidget {
  const WorkerTodayStripBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WorkerTodayStripComposed(
      onMarkDone: () {} /* TODO-לוח */,
      onTap: () {} /* TODO-לוח */,
      emphasized: true,
      name: '' /* TODO-לוח: String */,
      tag: '' /* TODO-לוח: String */,
      t: WorkerTodayStripTokens(),
    );
  }
}
