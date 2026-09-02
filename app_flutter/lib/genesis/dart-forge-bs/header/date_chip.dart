// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "header" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/header-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// DateChip — seam:date
class ForgeDateChip extends StatelessWidget {
  const ForgeDateChip({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(16, 14, 16, 14), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 16, children: [Container(width: 52, height: 56, decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(13)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [Text("LABEL", style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1)), Text("12", style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontSize: 22, fontWeight: FontWeight.w700, height: 1))])), Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.serifHe, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: -0.15, height: 1.05)), Container(margin: const EdgeInsets.fromLTRB(0, 2, 0, 0), child: Text("Meta", style: TextStyle(color: skin.mut, fontSize: 12.5, height: 1.45, fontFamily: fonts.he)))]))]));
  }
}
