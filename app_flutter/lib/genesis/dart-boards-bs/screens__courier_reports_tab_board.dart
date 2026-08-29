// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__courier_reports_tab.dart (בנייה-חכמה main) · מחווט: 0 · TODO: 5.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/config/app_brand.dart';
import 'package:buildsmart/data/repositories/courier_clock_repository.dart';
import 'package:buildsmart/data/supplier_data.dart';
import 'package:buildsmart/logic/calendar_days.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/persona_fulfillment.dart';
import 'package:buildsmart/state/rewards_state.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/sys_orders.dart';
import 'package:buildsmart/state/worker_notifs.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:buildsmart/widgets/photo_viewer.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dart-screens-bs/courier_reports_tab.g.dart';

class CourierReportsTabBoard extends ConsumerWidget {
  const CourierReportsTabBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CourierReportsTabComposed(
      children: const [] /* TODO-לוח: List<Widget> */,
      kvRowItems: const [] /* TODO-לוח: List<KvRowItem> */,
      label: '' /* TODO-לוח: String */,
      title: '' /* TODO-לוח: String */,
      value: '' /* TODO-לוח: String */,
      t: CourierReportsTabTokens(),
    );
  }
}
