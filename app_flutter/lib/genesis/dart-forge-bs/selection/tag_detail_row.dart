// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "selection" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/selection-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

// אייקון-פלייסהולדר ניטרלי (SVG המקורי אינו מתורגם — נשמר כתצורה, לא כפיקסל)
Widget _icon(Color c) => Icon(Icons.circle_outlined, size: 15, color: c);

/// TagDetailRow — seam:token
class ForgeTagDetailRow extends StatelessWidget {
  const ForgeTagDetailRow({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: skin.surface, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(15)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 11, children: [Row(mainAxisSize: MainAxisSize.min, spacing: 12, children: [Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 13)), Text("Meta", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 11))]), Row(mainAxisSize: MainAxisSize.min, spacing: 12, children: [Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 13)), Container(padding: const EdgeInsets.fromLTRB(11, 5, 6, 5), decoration: BoxDecoration(color: theme.a, border: Border.all(color: theme.a), borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.min, spacing: 5, children: [Text("Value", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), _icon(skin.mut)]))])]));
  }
}
