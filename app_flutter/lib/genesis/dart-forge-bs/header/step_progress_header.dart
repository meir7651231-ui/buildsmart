// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "header" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/header-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// StepProgressHeader — seam:progress
class ForgeStepProgressHeader extends StatelessWidget {
  const ForgeStepProgressHeader({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(18, 16, 18, 16), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Container(margin: const EdgeInsets.fromLTRB(0, 0, 0, 12), child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, spacing: 12, children: [Directionality(textDirection: TextDirection.ltr, child: Text.rich(TextSpan(children: [TextSpan(text: "3", style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontSize: 11, fontWeight: FontWeight.w700)), TextSpan(text: "/ 4", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 11, fontWeight: FontWeight.w600))]))), Directionality(textDirection: TextDirection.ltr, child: Text("Skip", style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontSize: 11, fontWeight: FontWeight.w600)))])), SizedBox(width: double.infinity, child: Container(height: 6, decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair2), borderRadius: BorderRadius.circular(999)), child: FractionallySizedBox(widthFactor: 0.750, alignment: Alignment.centerRight, child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.a, theme.aHi], begin: Alignment.centerLeft, end: Alignment.centerRight), borderRadius: BorderRadius.circular(999))))))]));
  }
}
