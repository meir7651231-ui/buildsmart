// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "header" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/header-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// GradientHeroCard — seam:title+cta
class ForgeGradientHeroCard extends StatelessWidget {
  const ForgeGradientHeroCard({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(constraints: const BoxConstraints(minHeight: 170), padding: const EdgeInsets.fromLTRB(20, 26, 20, 26), decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.c2, theme.a, theme.c3], begin: Alignment.topLeft, end: Alignment.bottomRight), border: Border.all(color: theme.a.withValues(alpha: 0.20)), borderRadius: BorderRadius.circular(16)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Directionality(textDirection: TextDirection.ltr, child: Container(margin: const EdgeInsets.fromLTRB(0, 0, 0, 8), child: Text("EYEBROW", style: TextStyle(color: const Color(0x9E0A0A0C), fontFamily: fonts.grotesk, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 2)))), Text("Label", style: TextStyle(color: const Color(0xFF0A0A0C), fontFamily: fonts.serifHe, fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -0.34, height: 1.05)), Opacity(opacity: 0.82, child: Container(margin: const EdgeInsets.fromLTRB(0, 7, 0, 0), child: Text("Meta", style: TextStyle(color: const Color(0xFF0A0A0C), fontSize: 13.5, height: 1.45, fontFamily: fonts.he)))), Container(margin: const EdgeInsets.fromLTRB(0, 16, 0, 0), child: Wrap(spacing: 10, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(15, 9, 15, 9), decoration: BoxDecoration(border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: Text("Action", style: TextStyle(color: const Color(0xFF0A0A0C), fontFamily: fonts.he, fontSize: 12, fontWeight: FontWeight.w600)))]))]));
  }
}
