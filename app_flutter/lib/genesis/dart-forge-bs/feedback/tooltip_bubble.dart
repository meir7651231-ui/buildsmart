// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "feedback" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/feedback-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// TooltipBubble — seam:fields
class ForgeTooltipBubble extends StatelessWidget {
  const ForgeTooltipBubble({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Label", style: TextStyle(color: skin.canvas, fontSize: 12, fontWeight: FontWeight.w600)), Row(mainAxisSize: MainAxisSize.min, spacing: 8, children: [Text("TooltipBubble"), Text("fields", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 7.5, fontWeight: FontWeight.w600))])]);
  }
}
