// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__manager_dashboard_screen.dart (בנייה-חכמה main) · מחווט: 0 · TODO: 21.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/manager_dashboard_screen.dart';
import 'package:buildsmart/data/board_accounts_local.dart';
import 'package:buildsmart/data/brands.dart';
import 'package:buildsmart/data/persona_data.dart';
import 'package:buildsmart/logic/manager_dashboard.dart';
import 'package:buildsmart/screens/catalog_settings_screen.dart';
import 'package:buildsmart/screens/chats_screen.dart';
import 'package:buildsmart/screens/intel/journey_labels.dart';
import 'package:buildsmart/screens/manager_copilot_screen.dart';
import 'package:buildsmart/screens/manager_profile_screen.dart';
import 'package:buildsmart/screens/manager_role_assign_sheet.dart';
import 'package:buildsmart/screens/regression_panel_screen.dart';
import 'package:buildsmart/screens/studio/studio_entry.dart';
import 'package:buildsmart/screens/studio_screen.dart';
import 'package:buildsmart/screens/trade_builder/system_setup_host_screen.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/manager_dashboard_state.dart';
import 'package:buildsmart/state/orders_engine.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:buildsmart/state/vacation_requests.dart';
import 'package:buildsmart/state/worker_notifs.dart';
import 'package:buildsmart/state/worker_tasks_engine.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/contact_actions.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:buildsmart/widgets/reject_reason_dialog.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import '../dart-screens-bs/manager_dashboard_screen.g.dart';

class ManagerDashboardScreenBoard extends ConsumerWidget {
  const ManagerDashboardScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ManagerDashboardScreenComposed(
      onOpen: () {} /* TODO-לוח */,
      onPressed: () {} /* TODO-לוח */,
      onTap: () {} /* TODO-לוח */,
      onTap2: () {} /* TODO-לוח */,
      badge: 0 /* TODO-לוח: int */,
      bordered: false /* TODO-לוח: bool */,
      categoryCount: 0 /* TODO-לוח: int */,
      child: const SizedBox.shrink() /* TODO-לוח: Widget */,
      count: 0 /* TODO-לוח: int */,
      emoji: '' /* TODO-לוח: String */,
      manageRowItems: const [] /* TODO-לוח: List<ManageRowItem> */,
      max: 0 /* TODO-לוח: int */,
      open: false /* TODO-לוח: bool */,
      pct: 0 /* TODO-לוח: int */,
      pipelineRowItems: const [] /* TODO-לוח: List<PipelineRowItem> */,
      productCount: 0 /* TODO-לוח: int */,
      sectionKey: '' /* TODO-לוח: String */,
      stageIdx: 0 /* TODO-לוח: int */,
      sub: '' /* TODO-לוח: String */,
      title: '' /* TODO-לוח: String */,
      titleCfgId: '' /* TODO-לוח: String */,
      t: ManagerDashboardScreenTokens(color: const Color(0xFF223047) /* TODO-לוח: טוקן */, textColor: const Color(0xFF223047) /* TODO-לוח: טוקן */),
    );
  }
}
