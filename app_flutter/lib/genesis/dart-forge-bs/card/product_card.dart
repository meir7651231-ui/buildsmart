// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "card" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/card-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// ProductCard — seam:fields
class ForgeProductCard extends StatelessWidget {
  const ForgeProductCard({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(15)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Container(height: 74, decoration: BoxDecoration(gradient: RadialGradient(center: Alignment(0.40, -0.80), radius: 1.20, colors: [theme.gl, skin.raised2], stops: [0.0, 0.60]), border: Border(bottom: BorderSide(color: skin.hair, width: 1)))), Container(padding: const EdgeInsets.fromLTRB(15, 11, 15, 12), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Label", style: TextStyle(color: skin.ink, fontSize: 13.5, fontFamily: fonts.he)), Container(padding: const EdgeInsets.fromLTRB(0, 6, 0, 7), child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [Text("Meta", style: TextStyle(color: skin.mut, fontSize: 12.5, fontFamily: fonts.he)), Directionality(textDirection: TextDirection.ltr, child: Text("248", style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 12.5, fontWeight: FontWeight.w700)))]))]))]));
  }
}
