// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "dataviz" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/dataviz-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';

/// 7 atoms — seam:fields
class Forge7Atoms extends StatelessWidget {
  const Forge7Atoms({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, spacing: 14, children: [Text("inherit LineChart →"), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("LineSpark"), Text("TrendChart"), Text("AreaChart"), Text("Timeline"), Text("OrderTimeline"), Text("DecisionLine"), Text("PipelineRow")])]);
  }
}
