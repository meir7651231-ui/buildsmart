// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__worker_reports_tab.dart (בנייה-חכמה main) · מחווט: 0 · TODO: 8.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/config/app_brand.dart';
import 'package:buildsmart/data/persona_data.dart';
import 'package:buildsmart/logic/calendar_days.dart';
import 'package:buildsmart/screens/worker_report_drilldowns.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/rewards_state.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:buildsmart/widgets/photo_viewer.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dart-screens-bs/worker_reports_tab.g.dart';

class WorkerReportsTabBoard extends ConsumerWidget {
  const WorkerReportsTabBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WorkerReportsTabComposed(
      onTap: () {} /* TODO-לוח */,
      children: const [] /* TODO-לוח: List<Widget> */,
      glyph: '' /* TODO-לוח: String */,
      label: '' /* TODO-לוח: String */,
      photo: '' /* TODO-לוח: String? */,
      title: '' /* TODO-לוח: String */,
      titleId: '' /* TODO-לוח: String? */,
      value: '' /* TODO-לוח: String */,
      t: WorkerReportsTabTokens(),
    );
  }
}
