// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "selection" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/selection-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

// אייקון-פלייסהולדר ניטרלי (SVG המקורי אינו מתורגם — נשמר כתצורה, לא כפיקסל)
Widget _icon(Color c) => Icon(Icons.circle_outlined, size: 15, color: c);

/// CheckPop — seam:state
class ForgeCheckPop extends StatelessWidget {
  const ForgeCheckPop({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: skin.surface, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(15)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 11, children: [Row(mainAxisSize: MainAxisSize.min, spacing: 11, children: [Container(decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.ink), borderRadius: BorderRadius.circular(7))), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 13)), Text("Meta · partial", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 10))])]), Row(mainAxisSize: MainAxisSize.min, spacing: 11, children: [Container(decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.ink), borderRadius: BorderRadius.circular(7)), child: _icon(skin.mut)), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 13)), Text("Meta", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 10))])])]));
  }
}
