// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__budget_screen.dart (בנייה-חכמה main) · מחווט: 2 · TODO: 5.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/budget_screen.dart';
import 'package:buildsmart/data/contractor_seeds.dart';
import 'package:buildsmart/data/repositories/site_local.dart';
import 'package:buildsmart/logic/input_validators.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:buildsmart/screens/budget_screen.dart';
import 'package:buildsmart/data/repositories/site_local.dart';
import '../dart-screens-bs/budget_screen.g.dart';

class BudgetScreenBoard extends ConsumerWidget {
  const BudgetScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = ref.watch(budgetProvider);
    final projects = ref.watch(siteRepositoryProvider).projects();
    final i = ref.read(budgetProvider.notifier).addCategory();
    final totalCtl = TextEditingController(text: b.total.toString());
    final over = b.left < 0;
    return BudgetScreenComposed(
      onTap: () {} /* TODO-לוח */,
      validator: (_) {} /* TODO-לוח */,
      child: const SizedBox.shrink() /* TODO-לוח: Widget */,
      controller: totalCtl,
      name: projects[i].name,
      number: false /* TODO-לוח: bool */,
      value: '' /* TODO-לוח: String */,
      t: BudgetScreenTokens(color: const Color(0xFF223047) /* TODO-לוח: טוקן */),
    );
  }
}
