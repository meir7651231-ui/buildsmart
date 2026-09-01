// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "spatial" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/spatial-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

// אייקון-פלייסהולדר ניטרלי (SVG המקורי אינו מתורגם — נשמר כתצורה, לא כפיקסל)
Widget _icon(Color c) => Icon(Icons.circle_outlined, size: 15, color: c);

/// TreeGrid — seam:fields
class ForgeTreeGrid extends StatelessWidget {
  const ForgeTreeGrid({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.all(16), child: Container(decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 13), child: Row(mainAxisSize: MainAxisSize.min, spacing: 9, children: [_icon(skin.mut), Text("Label"), Text("1,024", style: TextStyle(fontFamily: fonts.grotesk, fontFeatures: const [FontFeature.tabularFigures()]))])), Container(padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 13), child: Row(mainAxisSize: MainAxisSize.min, spacing: 9, children: [_icon(skin.mut), Text("Label"), Text("640", style: TextStyle(fontFamily: fonts.grotesk, fontFeatures: const [FontFeature.tabularFigures()]))])), Container(padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 13), child: Row(mainAxisSize: MainAxisSize.min, spacing: 9, children: [_icon(skin.mut), Text("Label"), Text("248", style: TextStyle(fontFamily: fonts.grotesk, fontFeatures: const [FontFeature.tabularFigures()]))])), Container(padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 13), child: Row(mainAxisSize: MainAxisSize.min, spacing: 9, children: [_icon(skin.mut), Text("Label"), Text("392", style: TextStyle(fontFamily: fonts.grotesk, fontFeatures: const [FontFeature.tabularFigures()]))])), Container(padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 13), child: Row(mainAxisSize: MainAxisSize.min, spacing: 9, children: [_icon(skin.mut), Text("Label"), Text("384", style: TextStyle(fontFamily: fonts.grotesk, fontFeatures: const [FontFeature.tabularFigures()]))])), Container(padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 13), child: Row(mainAxisSize: MainAxisSize.min, spacing: 9, children: [_icon(skin.mut), Text("Label"), Text("240", style: TextStyle(fontFamily: fonts.grotesk, fontFeatures: const [FontFeature.tabularFigures()]))]))])));
  }
}
