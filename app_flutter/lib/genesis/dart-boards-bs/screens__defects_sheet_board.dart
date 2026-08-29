// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: screens__defects_sheet.dart (בנייה-חכמה main) · מחווט: 2 · TODO: 1.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/state/board_auth.dart';
import 'package:buildsmart/state/tasks_engine.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/studio/cfg_text.dart';
import 'package:buildsmart/widgets/toast.dart';
import '../dart-screens-bs/defects_sheet.g.dart';

class DefectsSheetBoard extends ConsumerWidget {
  const DefectsSheetBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefectsSheetComposed(
      onTap: () {} /* TODO-לוח */,
      label: _kSeverities[i],
      selected: severity == _kSeverities[i],
      t: DefectsSheetTokens(),
    );
  }
}
