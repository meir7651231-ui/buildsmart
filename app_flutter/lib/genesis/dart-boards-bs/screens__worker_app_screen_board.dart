// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__worker_app_screen.dart (בנייה-חכמה main) · מחווט: 1 · TODO: 15.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/worker_app_screen.dart';
import 'package:buildsmart/data/persona_data.dart';
import 'package:buildsmart/data/task_skus_local.dart';
import 'package:buildsmart/screens/barcode_scanner.dart';
import 'package:buildsmart/screens/chats_screen.dart';
import 'package:buildsmart/screens/defects_sheet.dart';
import 'package:buildsmart/screens/docs_readiness_gate.dart';
import 'package:buildsmart/screens/lipskey_product_sheet.dart';
import 'package:buildsmart/screens/tasks_gantt_sheet.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/screens/worker_attendance_screen.dart';
import 'package:buildsmart/screens/worker_employer_stock_sheet.dart';
import 'package:buildsmart/screens/worker_equipment_checklist_sheet.dart';
import 'package:buildsmart/screens/worker_notifs_sheet.dart';
import 'package:buildsmart/screens/worker_profile_screen.dart';
import 'package:buildsmart/screens/worker_reports_tab.dart';
import 'package:buildsmart/screens/worker_settings_screen.dart';
import 'package:buildsmart/screens/worker_task_board_screen.dart';
import 'package:buildsmart/screens/worker_task_detail_sheet.dart';
import 'package:buildsmart/screens/worker_today_strip.dart';
import 'package:buildsmart/services/geo.dart';
import 'package:buildsmart/services/nav_launch.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/docs_readiness.dart';
import 'package:buildsmart/state/org_gates.dart';
import 'package:buildsmart/state/smart_project_engine.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:buildsmart/state/worker_attendance.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:buildsmart/widgets/voice_dictate_button.dart';
import '../dart-screens-bs/worker_app_screen.g.dart';

class WorkerAppScreenBoard extends ConsumerWidget {
  const WorkerAppScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WorkerAppScreenComposed(
      onPressed: () {} /* TODO-לוח */,
      onTap: () {} /* TODO-לוח */,
      chatOn: false /* TODO-לוח: bool */,
      currentIndex: 0 /* TODO-לוח: int */,
      deliveryFee: 0 /* TODO-לוח: int */,
      label: '' /* TODO-לוח: String */,
      label2: '' /* TODO-לוח: String */,
      label3: '' /* TODO-לוח: String */,
      label4: '' /* TODO-לוח: String */,
      label5: '' /* TODO-לוח: String */,
      subtotal: 0 /* TODO-לוח: int */,
      text: 'שם המשימה',
      total: 0 /* TODO-לוח: int */,
      value: '' /* TODO-לוח: String */,
      vat: 0 /* TODO-לוח: int */,
      vatInclusive: false /* TODO-לוח: bool */,
      t: WorkerAppScreenTokens(),
    );
  }
}
