// 🔌 חולל ע"י מחולל-הלוחות (board-gen) — הלוח = המקום-היחיד שנוגע-בחיווט (חוק-3).
// מקור-החיווט: features__fittings__intel__build_plan_screen.dart (בנייה-חכמה main) · מחווט: 0 · TODO: 4.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:buildsmart/features/fittings/intel/build_plan_screen.dart';
import 'package:buildsmart/features/fittings/engine/models.dart';
import 'package:buildsmart/features/fittings/intel/line_cuts.dart';
import 'package:buildsmart/features/fittings/render/route_preview.dart';
import '../dart-screens-bs/fittings_intel_build_plan_screen.g.dart';

class FittingsIntelBuildPlanScreenBoard extends ConsumerWidget {
  const FittingsIntelBuildPlanScreenBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FittingsIntelBuildPlanScreenComposed(
      cutLength: 0.0 /* TODO-לוח: double */,
      fromFamily: '' /* TODO-לוח: String */,
      od: 0 /* TODO-לוח: int */,
      toFamily: '' /* TODO-לוח: String */,
      t: FittingsIntelBuildPlanScreenTokens(),
    );
  }
}
