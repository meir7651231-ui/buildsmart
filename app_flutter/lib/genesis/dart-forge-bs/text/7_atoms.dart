// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "text" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/text-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// 7 atoms — seam:fields
class Forge7Atoms extends StatelessWidget {
  const Forge7Atoms({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Row(mainAxisSize: MainAxisSize.min, spacing: 14, children: [Text("ABC · 123", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 11, fontWeight: FontWeight.w600)), Text("inherit Overline →"), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Eyebrow"), Text("Overline"), Text("SectionLabel"), Text("SectionTitle"), Text("CaSubTitle"), Text("FieldLabel"), Text("EmojiSectionTitle")])]);
  }
}
