// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__manager_profile_screen.dart (בנייה-חכמה main) · מחווט: 0 · TODO: 2.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/data/supplier_data.dart';
import 'package:buildsmart/screens/catalog_settings_screen.dart';
import 'package:buildsmart/screens/manager_screens_sheet.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/sys_orders.dart';
import 'package:buildsmart/state/under_construction.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import '../dart-screens-bs/manager_profile_screen.g.dart';

class ManagerProfileScreenBoard extends ConsumerWidget {
  const ManagerProfileScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ManagerProfileScreenComposed(
      label: '' /* TODO-לוח: String */,
      value: '' /* TODO-לוח: String */,
      t: ManagerProfileScreenTokens(),
    );
  }
}
