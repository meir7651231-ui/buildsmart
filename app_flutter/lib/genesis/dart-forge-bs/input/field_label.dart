// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "input" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/input-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// FieldLabel — seam:fields
class ForgeFieldLabel extends StatelessWidget {
  const ForgeFieldLabel({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Text.rich(TextSpan(children: [WidgetSpan(alignment: PlaceholderAlignment.middle, child: Text.rich(TextSpan(children: [TextSpan(text: "Label", style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w600)), TextSpan(text: "*", style: TextStyle(color: theme.aHi, fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w600))]), textAlign: TextAlign.right)), WidgetSpan(alignment: PlaceholderAlignment.middle, child: Text("Meta · required label atom", textAlign: TextAlign.right, style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 9.5)))]));
  }
}
