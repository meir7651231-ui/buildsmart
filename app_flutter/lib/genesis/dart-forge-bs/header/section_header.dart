// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "header" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/header-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

// אייקון-פלייסהולדר ניטרלי (SVG המקורי אינו מתורגם — נשמר כתצורה, לא כפיקסל)
Widget _icon(Color c) => Icon(Icons.circle_outlined, size: 15, color: c);

/// SectionHeader — seam:title+link
class ForgeSectionHeader extends StatelessWidget {
  const ForgeSectionHeader({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 22), decoration: BoxDecoration(color: skin.surface, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Row(mainAxisSize: MainAxisSize.min, spacing: 16, children: [Container(decoration: BoxDecoration(color: theme.gl, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(9)), child: _icon(skin.mut)), Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.serifHe, fontWeight: FontWeight.w700)), Text("24", style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontSize: 10, fontWeight: FontWeight.w700)), Row(mainAxisSize: MainAxisSize.min, spacing: 5, children: [Text("See all", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), _icon(skin.mut)])]));
  }
}
