// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "dataviz" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/dataviz-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// ChartLegend — seam:series
class ForgeChartLegend extends StatelessWidget {
  const ForgeChartLegend({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(16, 16, 16, 13), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 11, children: [Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, spacing: 10, children: [Text("Label", style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 12, fontWeight: FontWeight.w600))]), Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 10, children: [Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 7, children: [Container(width: 11, height: 11, decoration: BoxDecoration(color: theme.a, borderRadius: BorderRadius.circular(3))), Text("Label", style: TextStyle(color: skin.mut, fontFamily: fonts.he)), Text("164", style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontWeight: FontWeight.w700))]), Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 7, children: [Container(width: 11, height: 11, decoration: BoxDecoration(color: theme.c2, borderRadius: BorderRadius.circular(3))), Text("Label", style: TextStyle(color: skin.mut, fontFamily: fonts.he)), Text("86", style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontWeight: FontWeight.w700))]), Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 7, children: [Container(width: 11, height: 11, decoration: BoxDecoration(color: theme.c3, borderRadius: BorderRadius.circular(3))), Text("Label", style: TextStyle(color: skin.mut, fontFamily: fonts.he)), Text("73", style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontWeight: FontWeight.w700))])])]));
  }
}
