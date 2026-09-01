// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "header" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/header-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

// אייקון-פלייסהולדר ניטרלי (SVG המקורי אינו מתורגם — נשמר כתצורה, לא כפיקסל)
Widget _icon(Color c) => Icon(Icons.circle_outlined, size: 15, color: c);

/// PageHeader — seam:title+actions
class ForgePageHeader extends StatelessWidget {
  const ForgePageHeader({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 22), decoration: BoxDecoration(color: skin.surface, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Row(mainAxisSize: MainAxisSize.min, spacing: 16, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Section", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 10, fontWeight: FontWeight.w600)), Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.serifHe, fontWeight: FontWeight.w700)), Text("Meta · a one-line summary of what this page holds, kept quiet in muted ink.", style: TextStyle(color: skin.mut, fontSize: 12.5))]), Container(decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: _icon(skin.mut)), Container(decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: _icon(skin.mut)), Container(padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 15), decoration: BoxDecoration(color: skin.raised, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: Row(mainAxisSize: MainAxisSize.min, spacing: 7, children: [_icon(skin.mut), Text("Action", style: TextStyle(color: skin.ink, fontFamily: fonts.he))]))]));
  }
}
