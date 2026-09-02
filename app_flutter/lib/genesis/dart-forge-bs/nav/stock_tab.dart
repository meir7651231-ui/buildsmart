// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "nav" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/nav-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// StockTab — seam:collection
class ForgeStockTab extends StatelessWidget {
  const ForgeStockTab({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(14)), child: Container(decoration: BoxDecoration(border: Border(bottom: BorderSide(color: skin.hair, width: 1))), child: Stack(clipBehavior: Clip.none, children: [Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, spacing: 4, children: [Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(14, 11, 14, 11), child: Center(widthFactor: 1.0, heightFactor: 1.0, child: Text("Label", style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w600)))), Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(14, 11, 14, 11), child: Center(widthFactor: 1.0, heightFactor: 1.0, child: Text("Label", style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w600))))]), Positioned(bottom: -1, child: Container(height: 2.5, decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.centerLeft, end: Alignment.centerRight), borderRadius: BorderRadius.circular(2), boxShadow: [BoxShadow(color: theme.gl, offset: const Offset(0, 0), blurRadius: 10, spreadRadius: 0)])))])));
  }
}
