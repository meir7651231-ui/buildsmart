// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__budget_screen.dart (בנייה-חכמה main) · מחווט: 6 · TODO: 1.
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
      child: Container(
              padding: const EdgeInsets.symmetric(vertical: 22),
              decoration: BoxDecoration(
                color: over
                    ? const Color(0xFFFFF0F0)
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: over ? const Color(0xFFFFD0D0) : const Color(0xFFEAEAEA)),
              ),
              child: Column(
                children: [
                  Text('${b.pct}%',
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: over ? _danger : _ink)),
                  const SizedBox(height: 2),
                  Text(
                      (over ? 'חריגה מהתקציב' : 'מהתקציב נוצל') + ' · הקש לעריכה',
                      style: const TextStyle(fontSize: 12, color: _muted)),
                ],
              ),
            ),
      controller: totalCtl,
      label: totalCtl.label,
      name: projects[i].name,
      number: totalCtl.number,
      value: _fmt(b.total),
      t: BudgetScreenTokens(color: const Color(0xFF223047) /* TODO-לוח: טוקן */),
    );
  }
}
