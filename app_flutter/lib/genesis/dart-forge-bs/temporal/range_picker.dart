// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "temporal" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/temporal-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// RangePicker — seam:fields
class ForgeRangePicker extends StatelessWidget {
  const ForgeRangePicker({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Container(margin: const EdgeInsets.fromLTRB(0, 0, 0, 5), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 3, children: [Text("א", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Text("ב", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Text("ג", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Text("ד", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Text("ה", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Text("ו", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Text("ש", style: TextStyle(color: skin.ink, fontFamily: fonts.he))])), const SizedBox.shrink()]));
  }
}
