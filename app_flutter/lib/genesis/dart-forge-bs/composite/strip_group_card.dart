// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "composite" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/composite-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

// אייקון-פלייסהולדר ניטרלי (SVG המקורי אינו מתורגם — נשמר כתצורה, לא כפיקסל)
Widget _icon(Color c) => Icon(Icons.circle_outlined, size: 15, color: c);

/// StripGroupCard — seam:fields
class ForgeStripGroupCard extends StatelessWidget {
  const ForgeStripGroupCard({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(decoration: BoxDecoration(color: skin.surface, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(18)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18), child: Row(mainAxisSize: MainAxisSize.min, spacing: 12, children: [_icon(skin.mut), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Label"), Text("Meta")]), Container(padding: const EdgeInsets.all(0), decoration: BoxDecoration(color: skin.raised2, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)))])), Container(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 14, children: [Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0), child: Row(mainAxisSize: MainAxisSize.min, spacing: 12, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Label"), Text("Meta")]), Text("Value", style: TextStyle(fontFamily: fonts.grotesk, fontSize: 13.5))])), Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0), child: Row(mainAxisSize: MainAxisSize.min, spacing: 12, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Label"), Text("Meta")]), Container(padding: const EdgeInsets.all(0), decoration: BoxDecoration(color: skin.raised2, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)))])), Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0), child: Row(mainAxisSize: MainAxisSize.min, spacing: 12, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Label"), Text("Meta")]), Container(padding: const EdgeInsets.all(0), decoration: BoxDecoration(color: skin.raised2, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)))]))]))]));
  }
}
