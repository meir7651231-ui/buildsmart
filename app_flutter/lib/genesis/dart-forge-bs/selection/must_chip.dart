// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "selection" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/selection-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

// אייקון-פלייסהולדר ניטרלי (SVG המקורי אינו מתורגם — נשמר כתצורה, לא כפיקסל)
Widget _icon(Color c) => Icon(Icons.circle_outlined, size: 15, color: c);

/// MustChip — seam:choice
class ForgeMustChip extends StatelessWidget {
  const ForgeMustChip({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: skin.surface, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(15)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 11, children: [Row(mainAxisSize: MainAxisSize.min, spacing: 8, children: [Container(padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 13), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.min, spacing: 6, children: [_icon(skin.mut), Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.he))])), Text("Label", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 11, fontWeight: FontWeight.w600)), Text("Label", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 11, fontWeight: FontWeight.w600))])]));
  }
}
