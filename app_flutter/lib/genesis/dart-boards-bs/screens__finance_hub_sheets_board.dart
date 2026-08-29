// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__finance_hub_sheets.dart (בנייה-חכמה main) · מחווט: 9 · TODO: 14.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      allocated: s.allocated,
      amount: p.amount,
      big: false /* TODO-לוח: bool */,
      children: this.children,
      fallback: '' /* TODO-לוח: String */,
      ic: '' /* TODO-לוח: String */,
      id: p.id,
      label: this.label,
      label2: '' /* TODO-לוח: String */,
      name: '' /* TODO-לוח: String */,
      note: '' /* TODO-לוח: String? */,
      secondLabel: '' /* TODO-לוח: String? */,
      secondValue: '' /* TODO-לוח: String? */,
      spent: s.spent,
      sub: '' /* TODO-לוח: String */,
      text: 'אין בקשות לאישור',
      thrRowItems: thr.map((t) => ThrRowItem(label: '${t.$1} — ${t.$2}', hit: pct >= t.$3)).toList(),
      title: '' /* TODO-לוח: String */,
      value: this.value,
      workerLabel: '' /* TODO-לוח: String */,
      t: FinanceHubSheetsTokens(valueColor: const Color(0xFF223047) /* TODO-לוח: טוקן */),
    );
  }
}
