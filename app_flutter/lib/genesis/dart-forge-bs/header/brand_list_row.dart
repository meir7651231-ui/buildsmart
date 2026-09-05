// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "header" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/header-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// BrandListRow — seam:mark
class ForgeBrandListRow extends StatelessWidget {
  const ForgeBrandListRow({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(16, 15, 16, 15), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Wrap(spacing: 14, runSpacing: 14, crossAxisAlignment: WrapCrossAlignment.center, children: [Container(width: 34, height: 34, alignment: Alignment.center, decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: theme.gl, offset: const Offset(0, 6), blurRadius: 18, spreadRadius: 0)]), child: Text("L", style: TextStyle(color: const Color(0xFF0A0A0C), fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 15, fontWeight: FontWeight.w700))), Directionality(textDirection: TextDirection.ltr, child: Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.serif, fontFamilyFallback: [fonts.serifHe], fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.32)))]));
  }
}
