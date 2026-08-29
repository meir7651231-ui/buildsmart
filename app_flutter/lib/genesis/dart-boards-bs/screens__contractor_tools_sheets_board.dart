// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__contractor_tools_sheets.dart (בנייה-חכמה main) · מחווט: 1 · TODO: 0.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/screens/contractor_tools_sheets.dart';
import 'package:buildsmart/config/app_brand.dart';
import 'package:buildsmart/data/contractor_seeds.dart';
import 'package:buildsmart/state/smart_cart.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/studio/cfg_visible.dart';
import 'package:buildsmart/widgets/toast.dart';
import '../dart-screens-bs/contractor_tools_sheets.g.dart';

class ContractorToolsSheetsBoard extends ConsumerWidget {
  const ContractorToolsSheetsBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ContractorToolsSheetsComposed(
      onPressed: () => Navigator.of(context).pop(),
      t: ContractorToolsSheetsTokens(),
    );
  }
}
