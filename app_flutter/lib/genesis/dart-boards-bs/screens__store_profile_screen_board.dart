// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__store_profile_screen.dart (בנייה-חכמה main) · מחווט: 1 · TODO: 0.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/store_profile_screen.dart';
import 'package:buildsmart/data/supplier_data.dart';
import 'package:buildsmart/logic/input_validators.dart';
import 'package:buildsmart/screens/store_documents_sheet.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/services/task_photo.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/store_profile_store.dart';
import 'package:buildsmart/state/sys_orders.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/contact_actions.dart';
import 'package:buildsmart/widgets/photo_viewer.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/services.dart';
import '../dart-screens-bs/store_profile_screen.g.dart';

class StoreProfileScreenBoard extends ConsumerWidget {
  const StoreProfileScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(sysOrdersProvider);
    return StoreProfileScreenComposed(
      sStatItems: const [
                OrderStage.newOrder,
                OrderStage.preparing,
                OrderStage.ready,
              ].map((s) => SStatItem(value: '${orders.countAt(s)}', label: kOrderStageLabel[s]!)).toList(),
      t: StoreProfileScreenTokens(),
    );
  }
}
