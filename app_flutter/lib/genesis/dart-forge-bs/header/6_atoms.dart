// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "header" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/header-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

// אייקון-פלייסהולדר ניטרלי (SVG המקורי אינו מתורגם — נשמר כתצורה, לא כפיקסל)
Widget _icon(Color c) => Icon(Icons.circle_outlined, size: 15, color: c);

/// 6 atoms — seam:title+link
class Forge6Atoms extends StatelessWidget {
  const Forge6Atoms({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    return Row(mainAxisSize: MainAxisSize.min, spacing: 14, children: [Container(decoration: BoxDecoration(color: theme.gl, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(9)), child: _icon(skin.mut)), Text("inherit SectionHeader →"), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("TitledSection"), Text("SectionTitle"), Text("EmojiSectionTitle"), Text("LensGroupHeader"), Text("CaSubTitle"), Text("SettingsSectionHead")])]);
  }
}
