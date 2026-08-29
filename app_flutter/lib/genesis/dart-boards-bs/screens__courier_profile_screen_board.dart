// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__courier_profile_screen.dart (בנייה-חכמה main) · מחווט: 4 · TODO: 1.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/courier_profile_screen.dart';
import 'package:buildsmart/data/board_accounts_local.dart';
import 'package:buildsmart/data/supplier_data.dart';
import 'package:buildsmart/logic/input_validators.dart';
import 'package:buildsmart/screens/courier_attendance_screen.dart';
import 'package:buildsmart/screens/courier_certs_screen.dart';
import 'package:buildsmart/screens/courier_forms_screen.dart';
import 'package:buildsmart/screens/courier_settings_screen.dart';
import 'package:buildsmart/screens/role_picker_sheet.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/screens/worker_payslips_sheet.dart';
import 'package:buildsmart/services/task_photo.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/courier_profile_store.dart';
import 'package:buildsmart/state/persona_fulfillment.dart';
import 'package:buildsmart/state/sys_orders.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/contact_actions.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:buildsmart/widgets/photo_viewer.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/services.dart';
import 'package:buildsmart/screens/courier_attendance_screen.dart';
import 'package:buildsmart/screens/courier_forms_screen.dart';
import 'package:buildsmart/screens/courier_certs_screen.dart';
import 'package:buildsmart/screens/worker_payslips_sheet.dart';
import '../dart-screens-bs/courier_profile_screen.g.dart';

class CourierProfileScreenBoard extends ConsumerWidget {
  const CourierProfileScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CourierProfileScreenComposed(
      onTap: () => Navigator.of(
                      context,
                    ).push(CourierAttendanceScreen.route()),
      onTap2: () =>
                        Navigator.of(context).push(CourierFormsScreen.route()),
      onTap3: () =>
                        Navigator.of(context).push(CourierCertsScreen.route()),
      onTap4: () => showWorkerPayslipsSheet(context),
      value: '' /* TODO-לוח: String */,
      t: CourierProfileScreenTokens(),
    );
  }
}
