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
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.fromLTRB(11, 8, 11, 8), decoration: BoxDecoration(color: skin.ink, borderRadius: BorderRadius.circular(9), boxShadow: [BoxShadow(color: const Color(0x80000000), offset: const Offset(0, 8), blurRadius: 22, spreadRadius: 0)]), child: Text("Label", style: TextStyle(color: skin.canvas, fontSize: 12, fontWeight: FontWeight.w600))), Container(margin: const EdgeInsets.fromLTRB(0, 2, 0, 0), child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, spacing: 8, children: [Text("TooltipBubble"), Container(padding: const EdgeInsets.fromLTRB(5, 1, 5, 1), decoration: BoxDecoration(border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Text("fields", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 7.5, fontWeight: FontWeight.w600)))]))]);
  }
}
