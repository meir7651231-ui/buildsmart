// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "feedback" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/feedback-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// LinearProgress — seam:fields
class ForgeLinearProgress extends StatelessWidget {
  const ForgeLinearProgress({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 9, children: [Container(decoration: BoxDecoration(color: skin.raised2, borderRadius: BorderRadius.circular(999)), child: const SizedBox.shrink()), Text("62%", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 11))]);
  }
}
