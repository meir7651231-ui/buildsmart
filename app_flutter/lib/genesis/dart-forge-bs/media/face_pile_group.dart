// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "media" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/media-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// FacePileGroup — seam:collection
class ForgeFacePileGroup extends StatelessWidget {
  const ForgeFacePileGroup({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(constraints: const BoxConstraints(minHeight: 88), child: Wrap(spacing: 14, runSpacing: 14, crossAxisAlignment: WrapCrossAlignment.center, children: [Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, children: [Container(width: 44, height: 44, alignment: Alignment.center, decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(44), boxShadow: [BoxShadow(color: skin.canvas, offset: const Offset(0, 0), blurRadius: 0, spreadRadius: 2.5)]), child: Text("L", style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.grotesk, fontSize: 44, fontWeight: FontWeight.w700, height: 1))), Container(width: 44, height: 44, alignment: Alignment.center, decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.c2, theme.a, theme.c3], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(44), boxShadow: [BoxShadow(color: skin.canvas, offset: const Offset(0, 0), blurRadius: 0, spreadRadius: 2.5)]), child: Text("L", style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.grotesk, fontSize: 44, fontWeight: FontWeight.w700, height: 1))), Directionality(textDirection: TextDirection.ltr, child: Container(width: 44, height: 44, alignment: Alignment.center, decoration: BoxDecoration(color: skin.raised2, borderRadius: BorderRadius.circular(50), boxShadow: [BoxShadow(color: skin.canvas, offset: const Offset(0, 0), blurRadius: 0, spreadRadius: 2.5)]), child: Text("+3", style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontSize: 13, fontWeight: FontWeight.w700))))])]));
  }
}
