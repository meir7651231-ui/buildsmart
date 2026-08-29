// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__contractor_material_requests_sheet.dart (בנייה-חכמה main) · מחווט: 0 · TODO: 1.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/contractor_material_requests_sheet.dart';
import 'package:buildsmart/state/material_requests_engine.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import '../dart-screens-bs/contractor_material_requests_sheet.g.dart';

class ContractorMaterialRequestsSheetBoard extends ConsumerWidget {
  const ContractorMaterialRequestsSheetBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ContractorMaterialRequestsSheetComposed(
      onTap: () {} /* TODO-לוח */,
      t: ContractorMaterialRequestsSheetTokens(color: const Color(0xFF223047) /* TODO-לוח: טוקן */),
    );
  }
}
