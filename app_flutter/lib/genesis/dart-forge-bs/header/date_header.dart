// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "header" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/header-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// DateHeader — seam:divider
class ForgeDateHeader extends StatelessWidget {
  const ForgeDateHeader({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(18, 12, 18, 12), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Container(padding: const EdgeInsets.fromLTRB(2, 6, 2, 6), child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 12, children: [Text("03", style: TextStyle(color: theme.aHi, fontFamily: fonts.serifHe, fontSize: 15, fontWeight: FontWeight.w700)), Text("LABEL", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2)), Expanded(child: Container(height: 1, decoration: BoxDecoration(color: skin.hair))), Text("4 items", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 10))])));
  }
}
