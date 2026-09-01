// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "spatial" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/spatial-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

// אייקון-פלייסהולדר ניטרלי (SVG המקורי אינו מתורגם — נשמר כתצורה, לא כפיקסל)
Widget _icon(Color c) => Icon(Icons.circle_outlined, size: 15, color: c);

/// SortHeader states — seam:fields
class ForgeSortHeaderStates extends StatelessWidget {
  const ForgeSortHeaderStates({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.all(16), child: Row(mainAxisSize: MainAxisSize.min, spacing: 14, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 8, children: [Row(mainAxisSize: MainAxisSize.min, spacing: 5, children: [Text("Value", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [_icon(skin.mut), _icon(skin.mut)])]), Text("unsorted")]), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 8, children: [Row(mainAxisSize: MainAxisSize.min, spacing: 5, children: [Text("Value", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [_icon(skin.mut), _icon(skin.mut)])]), Text("ascending")]), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 8, children: [Row(mainAxisSize: MainAxisSize.min, spacing: 5, children: [Text("Value", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [_icon(skin.mut), _icon(skin.mut)])]), Text("descending")])]));
  }
}
