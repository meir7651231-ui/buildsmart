// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__finance_hub_sheets.dart (בנייה-חכמה main) · מחווט: 1 · TODO: 25.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/finance_hub_sheets.dart';
import 'package:buildsmart/data/phaseb_seeds.dart';
import 'package:buildsmart/logic/finance_report_pdf.dart';
import 'package:buildsmart/logic/input_validators.dart';
import 'package:buildsmart/state/finance_hub_state.dart';
import 'package:buildsmart/state/pdf_print_seam.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/toast.dart';
import '../dart-screens-bs/finance_hub_sheets.g.dart';

class FinanceHubSheetsBoard extends ConsumerWidget {
  const FinanceHubSheetsBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FinanceHubSheetsComposed(
      onApprove: () {} /* TODO-לוח */,
      onReject: () {} /* TODO-לוח */,
      onTap: () {} /* TODO-לוח */,
      allocated: 0 /* TODO-לוח: int */,
      amount: 0 /* TODO-לוח: int */,
      big: false /* TODO-לוח: bool */,
      children: const [] /* TODO-לוח: List<Widget> */,
      createdAt: '' /* TODO-לוח: String */,
      days: 0 /* TODO-לוח: int */,
      fallback: '' /* TODO-לוח: String */,
      ic: '' /* TODO-לוח: String */,
      id: '' /* TODO-לוח: String */,
      label: '' /* TODO-לוח: String */,
      label2: '' /* TODO-לוח: String */,
      name: '' /* TODO-לוח: String */,
      note: null /* TODO-לוח: String? */,
      perDay: 0 /* TODO-לוח: int */,
      secondLabel: null /* TODO-לוח: String? */,
      secondValue: null /* TODO-לוח: String? */,
      spent: 0 /* TODO-לוח: int */,
      sub: '' /* TODO-לוח: String */,
      text: 'אין בקשות לאישור',
      thrRowItems: const [] /* TODO-לוח: List<ThrRowItem> */,
      title: '' /* TODO-לוח: String */,
      value: '' /* TODO-לוח: String */,
      workerLabel: '' /* TODO-לוח: String */,
      t: FinanceHubSheetsTokens(valueColor: const Color(0xFF223047) /* TODO-לוח: טוקן */),
    );
  }
}
