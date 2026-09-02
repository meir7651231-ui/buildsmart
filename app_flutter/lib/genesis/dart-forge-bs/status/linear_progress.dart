// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "status" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/status-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// LinearProgress — seam:fields
class ForgeLinearProgress extends StatelessWidget {
  const ForgeLinearProgress({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(0, 6, 0, 6), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 7, children: [Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [Text("Label", style: TextStyle(color: skin.mut, fontSize: 11, fontWeight: FontWeight.w600, fontFamily: fonts.he)), Directionality(textDirection: TextDirection.ltr, child: Text("72%", style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontSize: 12, fontWeight: FontWeight.w700)))]), SizedBox(width: double.infinity, child: Container(height: 8, decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair2), borderRadius: BorderRadius.circular(999)), child: FractionallySizedBox(widthFactor: 0.720, alignment: Alignment.centerRight, child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.a, theme.aHi], begin: Alignment.centerLeft, end: Alignment.centerRight), borderRadius: BorderRadius.circular(999))))))]));
  }
}
