// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__regression_panel_screen.dart (בנייה-חכמה main) · מחווט: 0 · TODO: 11.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/test_harness/regression_state.dart';
import 'package:buildsmart/test_harness/runner.dart';
import 'package:buildsmart/test_harness/types.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import '../dart-screens-bs/regression_panel_screen.g.dart';

class RegressionPanelScreenBoard extends ConsumerWidget {
  const RegressionPanelScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RegressionPanelScreenComposed(
      deliveryFee: 0 /* TODO-לוח: int */,
      label: '' /* TODO-לוח: String */,
      label2: '' /* TODO-לוח: String */,
      label3: '' /* TODO-לוח: String */,
      label4: '' /* TODO-לוח: String */,
      label5: '' /* TODO-לוח: String */,
      subtotal: 0 /* TODO-לוח: int */,
      total: 0 /* TODO-לוח: int */,
      value: '' /* TODO-לוח: String */,
      vat: 0 /* TODO-לוח: int */,
      vatInclusive: false /* TODO-לוח: bool */,
      t: RegressionPanelScreenTokens(),
    );
  }
}
