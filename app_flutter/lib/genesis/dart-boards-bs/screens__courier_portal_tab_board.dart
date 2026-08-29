// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__courier_portal_tab.dart (בנייה-חכמה main) · מחווט: 3 · TODO: 1.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/data/supplier_data.dart';
import 'package:buildsmart/screens/chats_screen.dart';
import 'package:buildsmart/screens/persona_pod_sheet.dart';
import 'package:buildsmart/screens/persona_portal.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/sys_orders.dart';
import 'package:buildsmart/state/under_construction.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import '../dart-screens-bs/courier_portal_tab.g.dart';

class CourierPortalTabBoard extends ConsumerWidget {
  const CourierPortalTabBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CourierPortalTabComposed(
      onTap: () {} /* TODO-לוח */,
      haul: o.haul,
      sub: t.sub,
      title: t.title,
      t: CourierPortalTabTokens(),
    );
  }
}
