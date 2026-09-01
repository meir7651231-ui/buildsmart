// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "text" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/text-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// CodeBlock — seam:fields
class ForgeCodeBlock extends StatelessWidget {
  const ForgeCodeBlock({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 24), decoration: BoxDecoration(color: skin.surface, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Container(padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("// tokens"), Text("const"), Text("scale =", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Text("ramp"), Text("(", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Text("\"1.25\""), Text(");", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Text("return"), Text("scale.", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Text("step"), Text("(", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Text("\"body\""), Text(");", style: TextStyle(color: skin.ink, fontFamily: fonts.he))])));
  }
}
