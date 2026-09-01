// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "dataviz" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/dataviz-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

// אייקון-פלייסהולדר ניטרלי (SVG המקורי אינו מתורגם — נשמר כתצורה, לא כפיקסל)
Widget _icon(Color c) => Icon(Icons.circle_outlined, size: 15, color: c);

/// LineSpark — seam:collection
class ForgeLineSpark extends StatelessWidget {
  const ForgeLineSpark({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    return Container(padding: const EdgeInsets.fromLTRB(16, 16, 16, 13), decoration: BoxDecoration(color: skin.surface, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 11, children: [Container(padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 2), child: Row(mainAxisSize: MainAxisSize.min, spacing: 12, children: [Text("Label"), _icon(skin.mut), Text("+18%")])), Container(padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 2), child: Row(mainAxisSize: MainAxisSize.min, spacing: 12, children: [Text("Label"), _icon(skin.mut), Text("-6%")])), Container(padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 2), child: Row(mainAxisSize: MainAxisSize.min, spacing: 12, children: [Text("Label"), _icon(skin.mut), Text("+3%")]))]));
  }
}
