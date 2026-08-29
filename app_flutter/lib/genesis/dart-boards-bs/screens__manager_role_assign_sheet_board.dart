// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__manager_role_assign_sheet.dart (בנייה-חכמה main) · מחווט: 0 · TODO: 4.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/data/repositories/users_lookup.dart';
import 'package:buildsmart/state/auth_state.dart';
import 'package:buildsmart/state/telemetry.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/toast.dart';
import '../dart-screens-bs/manager_role_assign_sheet.g.dart';

class ManagerRoleAssignSheetBoard extends ConsumerWidget {
  const ManagerRoleAssignSheetBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ManagerRoleAssignSheetComposed(
      onPressed: () {} /* TODO-לוח */,
      busy: false /* TODO-לוח: bool */,
      enabled: false /* TODO-לוח: bool */,
      name: '' /* TODO-לוח: String */,
      t: ManagerRoleAssignSheetTokens(),
    );
  }
}
