// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__contractor_hr_sheet.dart (בנייה-חכמה main) · מחווט: 0 · TODO: 9.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/contractor_hr_sheet.dart';
import 'package:buildsmart/state/required_docs_policy.dart';
import 'package:buildsmart/state/sys_chat.dart';
import 'package:buildsmart/state/vacation_requests.dart';
import 'package:buildsmart/state/worker_certs.dart';
import 'package:buildsmart/state/worker_notifs.dart';
import 'package:buildsmart/state/worker_trainings.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/reject_reason_dialog.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/toast.dart';
import '../dart-screens-bs/contractor_hr_sheet.g.dart';

class ContractorHrSheetBoard extends ConsumerWidget {
  const ContractorHrSheetBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ContractorHrSheetComposed(
      onPressed: () {} /* TODO-לוח */,
      bordered: false /* TODO-לוח: bool */,
      id: '' /* TODO-לוח: String */,
      label: '' /* TODO-לוח: String */,
      range: '' /* TODO-לוח: String */,
      reason: '' /* TODO-לוח: String */,
      status: '' /* TODO-לוח: String */,
      vacationRowItems: const [] /* TODO-לוח: List<VacationRowItem> */,
      workerName: '' /* TODO-לוח: String */,
      t: ContractorHrSheetTokens(color: const Color(0xFF223047) /* TODO-לוח: טוקן */, textColor: const Color(0xFF223047) /* TODO-לוח: טוקן */),
    );
  }
}
