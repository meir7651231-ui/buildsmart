// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "dataviz" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/dataviz-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// IntensityStrip — seam:fields
class ForgeIntensityStrip extends StatelessWidget {
  const ForgeIntensityStrip({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(16, 16, 16, 13), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 11, children: [Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.baseline, spacing: 10, children: [Text("Label", style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 12, fontWeight: FontWeight.w600))]), Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Container(height: 24), Container(margin: const EdgeInsets.fromLTRB(0, 8, 0, 0), child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [Text("low", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 9)), Text("high", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 9))]))])]));
  }
}
