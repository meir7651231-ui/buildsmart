// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "header" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/header-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// StoreSupplierHeader — seam:mark
class ForgeStoreSupplierHeader extends StatelessWidget {
  const ForgeStoreSupplierHeader({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(16, 15, 16, 15), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Wrap(spacing: 14, runSpacing: 14, crossAxisAlignment: WrapCrossAlignment.center, children: [Container(width: 42, height: 42, alignment: Alignment.center, decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: theme.gl, offset: const Offset(0, 6), blurRadius: 18, spreadRadius: 0)]), child: Text("L", style: TextStyle(color: const Color(0xFF0A0A0C), fontFamily: fonts.grotesk, fontSize: 18, fontWeight: FontWeight.w700))), Directionality(textDirection: TextDirection.ltr, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.serif, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.32)), Container(margin: const EdgeInsets.fromLTRB(0, 2, 0, 0), child: Text("META", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 2)))])), Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(9, 2, 9, 2), decoration: BoxDecoration(color: theme.a.withValues(alpha: 0.15), border: Border.all(color: theme.a.withValues(alpha: 0.32)), borderRadius: BorderRadius.circular(999)), child: Text("Live", style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontSize: 10, fontWeight: FontWeight.w700))))]));
  }
}
