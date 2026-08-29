// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__budget_screen.dart (בנייה-חכמה main) · מחווט: 0 · TODO: 7.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/data/contractor_seeds.dart';
import 'package:buildsmart/data/repositories/site_local.dart';
import 'package:buildsmart/logic/input_validators.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/toast.dart';
import '../dart-screens-bs/budget_screen.g.dart';

class BudgetScreenBoard extends ConsumerWidget {
  const BudgetScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BudgetScreenComposed(
      onTap: () {} /* TODO-לוח */,
      child: null /* TODO-לוח: Widget */,
      controller: null /* TODO-לוח: TextEditingController */,
      label: '' /* TODO-לוח: String */,
      name: '' /* TODO-לוח: String */,
      number: false /* TODO-לוח: bool */,
      value: '' /* TODO-לוח: String */,
      t: BudgetScreenTokens(color: const Color(0xFF223047) /* TODO-לוח: טוקן */),
    );
  }
}
