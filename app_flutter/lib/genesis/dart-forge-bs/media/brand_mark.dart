// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "media" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/media-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

// אייקון-פלייסהולדר ניטרלי (SVG המקורי אינו מתורגם — נשמר כתצורה, לא כפיקסל)
Widget _icon(Color c) => Icon(Icons.circle_outlined, size: 15, color: c);

/// BrandMark — seam:fields
class ForgeBrandMark extends StatelessWidget {
  const ForgeBrandMark({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    return Row(mainAxisSize: MainAxisSize.min, spacing: 14, children: [Container(decoration: BoxDecoration(color: theme.aHi, borderRadius: BorderRadius.circular(12)), child: _icon(skin.mut)), Container(decoration: BoxDecoration(color: theme.aHi, borderRadius: BorderRadius.circular(12)), child: _icon(skin.mut))]);
  }
}
