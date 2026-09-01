// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "temporal" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/temporal-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// WeekStrip + DateCell theater — seam:fields
class ForgeWeekStripDateCellTheater extends StatelessWidget {
  const ForgeWeekStripDateCellTheater({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [const SizedBox.shrink(), Row(mainAxisSize: MainAxisSize.min, spacing: 10, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 7, children: [Text("12", style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontWeight: FontWeight.w600, fontFeatures: const [FontFeature.tabularFigures()])), Text("default")]), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 7, children: [Text("14", style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontWeight: FontWeight.w600, fontFeatures: const [FontFeature.tabularFigures()])), Text("today")]), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 7, children: [Text("18", style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontWeight: FontWeight.w600, fontFeatures: const [FontFeature.tabularFigures()])), Text("selected")]), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 7, children: [Text("21", style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontWeight: FontWeight.w600, fontFeatures: const [FontFeature.tabularFigures()])), Text("event")]), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 7, children: [Text("30", style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontWeight: FontWeight.w600, fontFeatures: const [FontFeature.tabularFigures()])), Text("disabled")])])]));
  }
}
