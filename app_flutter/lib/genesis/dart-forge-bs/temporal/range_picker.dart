// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "temporal" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/temporal-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// RangePicker — seam:fields
class ForgeRangePicker extends StatelessWidget {
  const ForgeRangePicker({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Row(crossAxisAlignment: CrossAxisAlignment.center, spacing: 3, children: [Expanded(flex: 1, child: Text("א", textAlign: TextAlign.center, style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 9.5, letterSpacing: 0.48))), Expanded(flex: 1, child: Text("ב", textAlign: TextAlign.center, style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 9.5, letterSpacing: 0.48))), Expanded(flex: 1, child: Text("ג", textAlign: TextAlign.center, style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 9.5, letterSpacing: 0.48))), Expanded(flex: 1, child: Text("ד", textAlign: TextAlign.center, style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 9.5, letterSpacing: 0.48))), Expanded(flex: 1, child: Text("ה", textAlign: TextAlign.center, style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 9.5, letterSpacing: 0.48))), Expanded(flex: 1, child: Text("ו", textAlign: TextAlign.center, style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 9.5, letterSpacing: 0.48))), Expanded(flex: 1, child: Text("ש", textAlign: TextAlign.center, style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 9.5, letterSpacing: 0.48)))]), const SizedBox(height: 5), const SizedBox.shrink()]));
  }
}
