// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "nav" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/nav-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// SegmentedPillToggle — seam:collection
class ForgeSegmentedPillToggle extends StatelessWidget {
  const ForgeSegmentedPillToggle({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(14)), child: SizedBox(width: double.infinity, child: Container(decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Stack(clipBehavior: Clip.none, children: [Positioned(top: 4, bottom: 4, left: 0, child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: theme.gl, offset: const Offset(0, 4), blurRadius: 14, spreadRadius: 0)]))), Padding(padding: const EdgeInsets.fromLTRB(4, 4, 4, 4), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [Expanded(child: Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(9, 9, 9, 9), decoration: BoxDecoration(borderRadius: BorderRadius.circular(999)), child: Center(widthFactor: 1.0, heightFactor: 1.0, child: Text("Label", style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 12.5, fontWeight: FontWeight.w600))))), Expanded(child: Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(9, 9, 9, 9), decoration: BoxDecoration(borderRadius: BorderRadius.circular(999)), child: Center(widthFactor: 1.0, heightFactor: 1.0, child: Text("Label", style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 12.5, fontWeight: FontWeight.w600))))), Expanded(child: Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(9, 9, 9, 9), decoration: BoxDecoration(borderRadius: BorderRadius.circular(999)), child: Center(widthFactor: 1.0, heightFactor: 1.0, child: Text("Label", style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 12.5, fontWeight: FontWeight.w600)))))]))]))));
  }
}
