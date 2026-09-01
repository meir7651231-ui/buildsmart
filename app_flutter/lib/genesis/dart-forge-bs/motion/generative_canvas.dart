// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "motion" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/motion-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// GenerativeCanvas — seam:fields
class ForgeGenerativeCanvas extends StatelessWidget {
  const ForgeGenerativeCanvas({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(height: 150, decoration: BoxDecoration(color: skin.sunken), child: Stack(clipBehavior: Clip.none, children: [const SizedBox.shrink(), Positioned(top: 10, left: 10, child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 6, children: [const SizedBox.shrink(), Text("Organism", style: TextStyle(color: skin.ink, fontFamily: fonts.he))]))]));
  }
}
