// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "header" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/header-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// SmartProjectHero — seam:title
class ForgeSmartProjectHero extends StatelessWidget {
  const ForgeSmartProjectHero({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(26, 24, 26, 24), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.raised, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), foregroundDecoration: BoxDecoration(gradient: RadialGradient(center: Alignment(0.64, -1.24), radius: 1.20, colors: [theme.gl, const Color(0x00000000)], stops: [0.0, 0.55]), borderRadius: BorderRadius.circular(16)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.start, spacing: 16, children: [Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Directionality(textDirection: TextDirection.ltr, child: Container(margin: const EdgeInsets.fromLTRB(0, 0, 0, 8), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 8, children: [Container(width: 22, height: 1, decoration: BoxDecoration(color: theme.a)), Text("Project", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 2))]))), Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.serifHe, fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.28, height: 1.05, leadingDistribution: TextLeadingDistribution.even)), const SizedBox(height: 7), IntrinsicWidth(child: Text("Meta", style: TextStyle(color: skin.mut, fontSize: 13.5, height: 1.45, leadingDistribution: TextLeadingDistribution.even, fontFamily: fonts.he)))])), Container(margin: const EdgeInsets.fromLTRB(0, 6, 0, 0), child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 7, children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: theme.a, borderRadius: BorderRadius.circular(999))), Container(width: 8, height: 8, decoration: BoxDecoration(color: theme.aHi, borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: theme.a, offset: const Offset(0, 0), blurRadius: 0, spreadRadius: 3)])), Container(width: 8, height: 8, decoration: BoxDecoration(color: skin.hair, borderRadius: BorderRadius.circular(999)))]))])]));
  }
}
