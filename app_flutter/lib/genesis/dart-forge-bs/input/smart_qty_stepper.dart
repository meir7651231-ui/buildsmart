// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "input" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/input-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// SmartQtyStepper — seam:fields
class ForgeSmartQtyStepper extends StatelessWidget {
  const ForgeSmartQtyStepper({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 8, children: [Container(decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [Container(width: 42, height: 44, alignment: Alignment.center, child: Text("−", style: TextStyle(color: skin.ink, fontSize: 18, fontFamily: fonts.he))), Directionality(textDirection: TextDirection.ltr, child: Container(constraints: const BoxConstraints(minWidth: 46), child: Text("1", textAlign: TextAlign.center, style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 16, fontWeight: FontWeight.w600)))), Container(width: 42, height: 44, alignment: Alignment.center, child: Text("+", style: TextStyle(color: skin.ink, fontSize: 18, fontFamily: fonts.he)))])), Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 6, children: [Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(10, 4, 10, 4), decoration: BoxDecoration(color: theme.a.withValues(alpha: 0.120), border: Border.all(color: theme.a.withValues(alpha: 0.300)), borderRadius: BorderRadius.circular(999)), child: Text("+5", style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11)))), Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(10, 4, 10, 4), decoration: BoxDecoration(color: theme.a.withValues(alpha: 0.120), border: Border.all(color: theme.a.withValues(alpha: 0.300)), borderRadius: BorderRadius.circular(999)), child: Text("+10", style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11)))), Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(10, 4, 10, 4), decoration: BoxDecoration(color: theme.a.withValues(alpha: 0.120), border: Border.all(color: theme.a.withValues(alpha: 0.300)), borderRadius: BorderRadius.circular(999)), child: Text("Max", style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11))))])]);
  }
}
