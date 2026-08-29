// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__worker_forms_screen.dart (בנייה-חכמה main) · מחווט: 1 · TODO: 14.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/worker_forms_screen.dart';
import 'package:buildsmart/logic/input_validators.dart';
import 'package:buildsmart/logic/printable_docs.dart';
import 'package:buildsmart/screens/welcome_screen.dart';
import 'package:buildsmart/services/doc_print.dart';
import 'package:buildsmart/services/task_photo.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/employer_link.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/vacation_requests.dart';
import 'package:buildsmart/state/worker_forms.dart';
import 'package:buildsmart/state/worker_profile_store.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/photo_viewer.dart';
import 'package:buildsmart/widgets/signature_pad.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:buildsmart/state/board_auth.dart';
import '../dart-screens-bs/worker_forms_screen.g.dart';

class WorkerFormsScreenBoard extends ConsumerWidget {
  const WorkerFormsScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(boardAuthProvider);
    return WorkerFormsScreenComposed(
      onApprove: () {} /* TODO-לוח */,
      onPressed: () {} /* TODO-לוח */,
      onReject: () async {} /* TODO-לוח */,
      children: const [] /* TODO-לוח: List<Widget> */,
      filled: false,
      id: '' /* TODO-לוח: String */,
      label: '' /* TODO-לוח: String */,
      label2: '' /* TODO-לוח: String */,
      label3: '' /* TODO-לוח: String */,
      label4: '' /* TODO-לוח: String */,
      range: '' /* TODO-לוח: String */,
      reason: '' /* TODO-לוח: String */,
      status: '' /* TODO-לוח: String */,
      title: '' /* TODO-לוח: String */,
      workerName: '' /* TODO-לוח: String */,
      t: WorkerFormsScreenTokens(),
    );
  }
}
