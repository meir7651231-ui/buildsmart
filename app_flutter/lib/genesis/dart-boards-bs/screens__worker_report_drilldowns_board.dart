// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__worker_report_drilldowns.dart (בנייה-חכמה main) · מחווט: 3 · TODO: 0.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/config/app_brand.dart';
import 'package:buildsmart/data/persona_data.dart';
import 'package:buildsmart/screens/worker_reports_tab.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/rewards_state.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/photo_viewer.dart';
import '../dart-screens-bs/worker_report_drilldowns.g.dart';

class WorkerReportDrilldownsBoard extends ConsumerWidget {
  const WorkerReportDrilldownsBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WorkerReportDrilldownsComposed(
      kvLineItems: rewards.challenges.map((c) => KvLineItem(label: c.name, value: c.done
                ? 'הושלם · +${c.reward} 🪙'
                : '${c.progress}/${c.goal} · +${c.reward} 🪙')).toList(),
      status: t.status,
      text: 'צ׳קליסט ציוד',
      t: WorkerReportDrilldownsTokens(),
    );
  }
}
