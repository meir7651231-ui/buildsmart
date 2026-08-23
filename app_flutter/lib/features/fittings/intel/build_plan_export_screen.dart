// 🧠 מנוע-אביזרים · E-lite slice 3 — מסך "ייצוא-מסמך" (יכולת-מאחורי-כפתור). מציג את
// מסמך-תוכנית-הבנייה כטקסט **ניתן-לבחירה** (העתקה-ידנית). מגודר · off-live.
// שיתוף/שמירה-לקובץ = תלות עתידית (החלטת-בעלים) — כאן תצוגה-והעתקה בלבד.
//
// 🔒 אף מסך-חי לא מייבא `intel/` ⇒ tree-shaken ⇒ הזרימה החיה byte-identical.

import 'package:buildsmart/features/fittings/intel/build_plan_export.dart';
import 'package:buildsmart/features/fittings/intel/line_planner.dart';
import 'package:buildsmart/features/fittings/render/route_preview.dart';
import 'package:flutter/material.dart';

/// מסך "ייצוא-מסמך": טקסט-תוכנית-הבנייה, ניתן-לבחירה+העתקה.
class BuildPlanExportScreen extends StatelessWidget {
  const BuildPlanExportScreen({required this.plan, super.key});

  final FittingLinePlan plan;

  @override
  Widget build(BuildContext context) {
    final doc = exportBuildPlanText(plan);
    return Scaffold(
      backgroundColor: kStageBackground,
      appBar: AppBar(
        backgroundColor: const Color(0xFF151F2A),
        foregroundColor: Colors.white,
        title: const Text(
          'ייצוא-מסמך · preview (off-live)',
          style: TextStyle(fontFamily: 'Heebo', fontWeight: FontWeight.w700),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: SelectableText(
            doc,
            style: const TextStyle(
                fontFamily: 'Heebo', color: Colors.white, fontSize: 14, height: 1.5,),
          ),
        ),
      ),
    );
  }
}
