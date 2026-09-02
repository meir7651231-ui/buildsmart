// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "text" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/text-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// CodeBlock — seam:fields
class ForgeCodeBlock extends StatelessWidget {
  const ForgeCodeBlock({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(18, 18, 18, 18), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(18, 15, 18, 15), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(12)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("// tokens", style: TextStyle(color: skin.faint, fontFamily: fonts.he)), Text("const", style: TextStyle(color: theme.aHi, fontFamily: fonts.he)), Text("scale =", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 12.5, height: 1.75)), Text("ramp", style: TextStyle(color: theme.c3, fontFamily: fonts.he)), Text("(", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 12.5, height: 1.75)), Text("\"1.25\"", style: TextStyle(color: theme.c2, fontFamily: fonts.he)), Text(");", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 12.5, height: 1.75)), Text("return", style: TextStyle(color: theme.aHi, fontFamily: fonts.he)), Text("scale.", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 12.5, height: 1.75)), Text("step", style: TextStyle(color: theme.c3, fontFamily: fonts.he)), Text("(", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 12.5, height: 1.75)), Text("\"body\"", style: TextStyle(color: theme.c2, fontFamily: fonts.he)), Text(");", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 12.5, height: 1.75))]))));
  }
}
