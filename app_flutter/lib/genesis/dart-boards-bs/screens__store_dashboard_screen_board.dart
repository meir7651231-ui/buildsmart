// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__store_dashboard_screen.dart (בנייה-חכמה main) · מחווט: 4 · TODO: 5.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/data/supplier_data.dart';
import 'package:buildsmart/logic/input_validators.dart';
import 'package:buildsmart/screens/chats_screen.dart';
import 'package:buildsmart/screens/persona_picking_sheet.dart';
import 'package:buildsmart/screens/persona_portal.dart';
import 'package:buildsmart/screens/store_profile_screen.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/services/task_photo.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/org_gates.dart';
import 'package:buildsmart/state/persona_fulfillment.dart';
import 'package:buildsmart/state/store_profile_store.dart';
import 'package:buildsmart/state/store_stock.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/sys_orders.dart';
import 'package:buildsmart/state/under_construction.dart';
import 'package:buildsmart/state/worker_notifs.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/contact_actions.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:buildsmart/widgets/photo_viewer.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dart-screens-bs/store_dashboard_screen.g.dart';

class StoreDashboardScreenBoard extends ConsumerWidget {
  const StoreDashboardScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StoreDashboardScreenComposed(
      onTap: () {} /* TODO-לוח */,
      badge: '' /* TODO-לוח: String */,
      child: CfgText(
                      'store_dashboard_screen.t01',
                      '✓ אין הזמנות שממתינות לאישור',
                      style: TextStyle(
                        color: BsTokens.inkLight.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
      label: f.$2,
      on: _orderFilter == f.$1,
      portalTileButtonItems: tiles.map((t) => PortalTileButtonItem(title: t.title, sub: t.sub, onTap: () => showPortalSheet(context, t))).toList(),
      sub: '' /* TODO-לוח: String */,
      title: '' /* TODO-לוח: String */,
      value: '' /* TODO-לוח: String */,
      t: StoreDashboardScreenTokens(color: const Color(0xFF223047) /* TODO-לוח: טוקן */),
    );
  }
}
