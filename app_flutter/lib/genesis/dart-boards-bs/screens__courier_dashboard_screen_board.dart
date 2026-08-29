// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__courier_dashboard_screen.dart (בנייה-חכמה main) · מחווט: 6 · TODO: 2.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/data/repositories/courier_clock_repository.dart';
import 'package:buildsmart/data/supplier_data.dart';
import 'package:buildsmart/screens/courier_delivery_detail_sheet.dart';
import 'package:buildsmart/screens/courier_portal_tab.dart';
import 'package:buildsmart/screens/courier_profile_screen.dart';
import 'package:buildsmart/screens/courier_reports_tab.dart';
import 'package:buildsmart/screens/courier_settings_screen.dart';
import 'package:buildsmart/screens/docs_readiness_gate.dart';
import 'package:buildsmart/screens/persona_pod_sheet.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/courier_clock.dart';
import 'package:buildsmart/state/courier_profile_store.dart';
import 'package:buildsmart/state/docs_readiness.dart';
import 'package:buildsmart/state/notif_settings.dart';
import 'package:buildsmart/state/persona_fulfillment.dart';
import 'package:buildsmart/state/rewards_state.dart';
import 'package:buildsmart/state/sys_orders.dart';
import 'package:buildsmart/state/worker_notifs.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/contact_actions.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dart-screens-bs/courier_dashboard_screen.g.dart';

class CourierDashboardScreenBoard extends ConsumerWidget {
  const CourierDashboardScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CourierDashboardScreenComposed(
      onTap: kHaulTypes[i].onTap,
      child: Text(
            toPickup > 0
                ? '$toPickup משלוחים ממתינים לאיסוף · אסוף מהחנות כדי להתחיל'
                : active > 0
                ? '🚚 $onRoad משלוחים בדרך — אין איסופים ממתינים'
                : '✓ אין משלוחים שמתאימים ל$haulName כרגע',
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
      ic: kHaulTypes[i].ic,
      label: '' /* TODO-לוח: String */,
      name: kHaulTypes[i].name,
      on: false,
      preferred: kHaulTypes[i].id == preferred,
      value: '' /* TODO-לוח: String */,
      t: CourierDashboardScreenTokens(),
    );
  }
}
