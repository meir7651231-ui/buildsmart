// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "list" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/list-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

// אייקון-פלייסהולדר ניטרלי (SVG המקורי אינו מתורגם — נשמר כתצורה, לא כפיקסל)
Widget _icon(Color c) => Icon(Icons.circle_outlined, size: 15, color: c);

/// SwipeRow — seam:fields
class ForgeSwipeRow extends StatelessWidget {
  const ForgeSwipeRow({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Container(decoration: BoxDecoration(color: skin.surface, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(15)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15), child: Row(mainAxisSize: MainAxisSize.min, spacing: 12, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [_icon(skin.mut), Text("Action", style: TextStyle(color: skin.ink, fontFamily: fonts.he))]), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [_icon(skin.mut), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Label"), Text("Meta")]), Text("248")])])), Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15), child: Row(mainAxisSize: MainAxisSize.min, spacing: 12, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [_icon(skin.mut), Text("Action", style: TextStyle(color: skin.ink, fontFamily: fonts.he))]), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [_icon(skin.mut), Text("Label"), Text("Meta", style: TextStyle(fontFamily: fonts.grotesk, fontSize: 9, fontWeight: FontWeight.w700))])]))])), Text("hover / tap a row to reveal the trailing action", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 9)), Row(mainAxisSize: MainAxisSize.min, spacing: 8, children: [Text("SwipeRow · live reveal", style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontSize: 10, fontWeight: FontWeight.w600)), Text("fields", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 7.5, fontWeight: FontWeight.w600))])]);
  }
}
