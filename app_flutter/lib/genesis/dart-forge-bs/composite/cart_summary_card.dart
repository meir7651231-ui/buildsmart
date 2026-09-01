// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "composite" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/composite-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

// אייקון-פלייסהולדר ניטרלי (SVG המקורי אינו מתורגם — נשמר כתצורה, לא כפיקסל)
Widget _icon(Color c) => Icon(Icons.circle_outlined, size: 15, color: c);

/// CartSummaryCard — seam:collection
class ForgeCartSummaryCard extends StatelessWidget {
  const ForgeCartSummaryCard({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(decoration: BoxDecoration(color: skin.surface, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(18)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18), child: Row(mainAxisSize: MainAxisSize.min, spacing: 12, children: [_icon(skin.mut), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Label"), Text("Meta · 3 items")])])), Container(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 14, children: [Container(padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 0), child: Row(mainAxisSize: MainAxisSize.min, spacing: 12, children: [Text("2", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 12, fontWeight: FontWeight.w600)), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Label"), Text("Meta")]), Text("124", style: TextStyle(fontFamily: fonts.grotesk, fontSize: 13.5))])), Container(padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 0), child: Row(mainAxisSize: MainAxisSize.min, spacing: 12, children: [Text("1", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 12, fontWeight: FontWeight.w600)), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Label"), Text("Meta")]), Text("86", style: TextStyle(fontFamily: fonts.grotesk, fontSize: 13.5))])), Container(padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 0), child: Row(mainAxisSize: MainAxisSize.min, spacing: 12, children: [Text("4", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 12, fontWeight: FontWeight.w600)), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Label"), Text("Meta")]), Text("212", style: TextStyle(fontFamily: fonts.grotesk, fontSize: 13.5))]))])), Container(padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18), child: Row(mainAxisSize: MainAxisSize.min, spacing: 10, children: [Row(mainAxisSize: MainAxisSize.min, children: [Text("Label"), Text("422")]), Row(mainAxisSize: MainAxisSize.min, children: [Text("Label"), Text("38")]), Row(mainAxisSize: MainAxisSize.min, children: [Text("Label"), Text("460")])]))]));
  }
}
