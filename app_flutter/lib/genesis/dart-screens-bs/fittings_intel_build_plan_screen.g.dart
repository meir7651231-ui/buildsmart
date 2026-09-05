// 🏗️ חולל ע"י המנוע-המרכיב (gen-screen) — אל תערוך ידנית; ערוך את המניפסט.
// מקור: features__fittings__intel__build_plan_screen.manifest.json · המסך = דאטה; הקוד הזה = חיווט-בלבד (חוק-2).
// שערים/callbacks/טוקנים מוזרקים ע"י הלוח — אפס-IO, אפס-תוכן, אפס-הכרעות כאן.
import 'package:flutter/material.dart';
import '../dart-ui-bs/auto/cut_tile.dart';
import '../dart-data-bs/auto/features__fittings__intel__build_plan_screen_content.dart';


/// טוקני-העיצוב שהמסך צורך — הלוח מזרים מקטלוג-הטוקנים.
class FittingsIntelBuildPlanScreenTokens {
  const FittingsIntelBuildPlanScreenTokens();

}

class FittingsIntelBuildPlanScreenComposed extends StatelessWidget {
  const FittingsIntelBuildPlanScreenComposed({required this.cutLength, required this.fromFamily, required this.od, required this.toFamily, required this.t, super.key});


  final double cutLength;
  final String fromFamily;
  final int od;
  final String toFamily;
  final FittingsIntelBuildPlanScreenTokens t;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          CutTile(
            label: cut_tile_label,
            label2: cut_tile_label2,
            cutLength: cutLength,
            fromFamily: fromFamily,
            od: od,
            toFamily: toFamily,
          ),
        ],
      );
}
