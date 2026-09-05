// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "header" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/header-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// SectionTitle — seam:title+link
class ForgeSectionTitle extends StatelessWidget {
  const ForgeSectionTitle({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(18, 15, 18, 15), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 16, children: [Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.serifHe, fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.17, height: 1.05, leadingDistribution: TextLeadingDistribution.even)), const SizedBox(height: 3), IntrinsicWidth(child: Text("Meta", style: TextStyle(color: skin.mut, fontSize: 12.5, height: 1.45, leadingDistribution: TextLeadingDistribution.even, fontFamily: fonts.he)))])), Flexible(child: Directionality(textDirection: TextDirection.ltr, child: Text("More", style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis, softWrap: false)))]));
  }
}
