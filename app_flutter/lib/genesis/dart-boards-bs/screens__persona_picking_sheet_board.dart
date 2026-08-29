// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__persona_picking_sheet.dart (בנייה-חכמה main) · מחווט: 0 · TODO: 3.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/persona_picking_sheet.dart';
import 'package:buildsmart/data/supplier_data.dart';
import 'package:buildsmart/state/persona_fulfillment.dart';
import 'package:buildsmart/state/sys_orders.dart';
import 'package:buildsmart/state/under_construction.dart';
import 'package:buildsmart/theme/app_theme.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/confirm_dialog.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import '../dart-screens-bs/persona_picking_sheet.g.dart';

class PersonaPickingSheetBoard extends ConsumerWidget {
  const PersonaPickingSheetBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PersonaPickingSheetComposed(
      onSelect: (_) {} /* TODO-לוח */,
      splitInto: 0 /* TODO-לוח: int */,
      text: '' /* TODO-לוח: String */,
      t: PersonaPickingSheetTokens(bg: const Color(0xFF223047) /* TODO-לוח: טוקן */, fg: const Color(0xFF223047) /* TODO-לוח: טוקן */),
    );
  }
}
