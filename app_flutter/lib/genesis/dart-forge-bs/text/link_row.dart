// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "text" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/text-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// LinkRow — seam:collection
class ForgeLinkRow extends StatelessWidget {
  const ForgeLinkRow({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(18, 18, 18, 18), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: IntrinsicWidth(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("שורה עם ", style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 14.5, height: 1.9, leadingDistribution: TextLeadingDistribution.even)), Container(decoration: BoxDecoration(border: Border(bottom: BorderSide(color: theme.a.withValues(alpha: 0.400), width: 1))), child: Text("קישור מודגש", style: TextStyle(color: theme.aHi, fontFamily: fonts.he, fontSize: 14.5, fontWeight: FontWeight.w600, height: 1.9, leadingDistribution: TextLeadingDistribution.even))), Text(" וגם ", style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 14.5, height: 1.9, leadingDistribution: TextLeadingDistribution.even)), Text("קו תחתון", style: TextStyle(color: theme.aHi, fontFamily: fonts.he, fontSize: 14.5, height: 1.9, leadingDistribution: TextLeadingDistribution.even)), Text(" בתוך פסקה — כל מצב נגזר מ-var(--a).", style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 14.5, height: 1.9, leadingDistribution: TextLeadingDistribution.even)), const SizedBox(height: 12), Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [Directionality(textDirection: TextDirection.ltr, child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 10, children: [Text("Label", style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontSize: 12, height: 1.9, leadingDistribution: TextLeadingDistribution.even)), Text("·", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 12, height: 1.9, leadingDistribution: TextLeadingDistribution.even)), Text("Label", style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontSize: 12, height: 1.9, leadingDistribution: TextLeadingDistribution.even)), Text("·", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 12, height: 1.9, leadingDistribution: TextLeadingDistribution.even)), Text("Meta", style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontSize: 12, height: 1.9, leadingDistribution: TextLeadingDistribution.even))]))])])));
  }
}
