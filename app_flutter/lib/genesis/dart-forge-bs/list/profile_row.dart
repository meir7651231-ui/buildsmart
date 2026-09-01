// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "list" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/list-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

// אייקון-פלייסהולדר ניטרלי (SVG המקורי אינו מתורגם — נשמר כתצורה, לא כפיקסל)
Widget _icon(Color c) => Icon(Icons.circle_outlined, size: 15, color: c);

/// ProfileRow — seam:fields
class ForgeProfileRow extends StatelessWidget {
  const ForgeProfileRow({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(decoration: BoxDecoration(color: skin.surface, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(15)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15), child: Row(mainAxisSize: MainAxisSize.min, spacing: 12, children: [Text("L"), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Label"), Text("Meta")]), _icon(skin.mut)])), Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15), child: Row(mainAxisSize: MainAxisSize.min, spacing: 12, children: [Text("L"), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Label"), Text("Meta")]), Text("OK", style: TextStyle(fontFamily: fonts.grotesk, fontSize: 9, fontWeight: FontWeight.w700)), _icon(skin.mut)])), Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15), child: Row(mainAxisSize: MainAxisSize.min, spacing: 12, children: [Text("L"), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Label"), Text("Meta")]), Text("92"), _icon(skin.mut)]))]));
  }
}
