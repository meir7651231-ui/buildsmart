// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__worker_profile_screen.dart (בנייה-חכמה main) · מחווט: 4 · TODO: 0.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/data/board_accounts_local.dart';
import 'package:buildsmart/logic/input_validators.dart';
import 'package:buildsmart/screens/role_picker_sheet.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/screens/worker_attendance_screen.dart';
import 'package:buildsmart/screens/worker_forms_screen.dart';
import 'package:buildsmart/screens/worker_payslips_sheet.dart';
import 'package:buildsmart/screens/worker_safety_screen.dart';
import 'package:buildsmart/screens/worker_settings_screen.dart';
import 'package:buildsmart/services/task_photo.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:buildsmart/state/vacation_requests.dart';
import 'package:buildsmart/state/worker_attendance.dart';
import 'package:buildsmart/state/worker_certs.dart';
import 'package:buildsmart/state/worker_forms.dart';
import 'package:buildsmart/state/worker_profile_store.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/contact_actions.dart';
import 'package:buildsmart/widgets/help_target.dart';
import 'package:buildsmart/widgets/photo_viewer.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import '../dart-screens-bs/worker_profile_screen.g.dart';

class WorkerProfileScreenBoard extends ConsumerWidget {
  const WorkerProfileScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WorkerProfileScreenComposed(
      done: done,
      inReview: inReview,
      rejected: rejected,
      total: mine.length,
      t: WorkerProfileScreenTokens(),
    );
  }
}
