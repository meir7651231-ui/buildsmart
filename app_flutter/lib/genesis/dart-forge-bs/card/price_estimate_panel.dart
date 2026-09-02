// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "card" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/card-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// PriceEstimatePanel — seam:fields
class ForgePriceEstimatePanel extends StatelessWidget {
  const ForgePriceEstimatePanel({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(14, 14, 14, 14), decoration: BoxDecoration(color: skin.surface, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(14)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.fromLTRB(0, 5, 0, 5), child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Directionality(textDirection: TextDirection.ltr, child: Text("248", style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk)))])), Container(padding: const EdgeInsets.fromLTRB(0, 5, 0, 5), child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Directionality(textDirection: TextDirection.ltr, child: Text("92", style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk)))])), Container(margin: const EdgeInsets.fromLTRB(0, 6, 0, 0), padding: const EdgeInsets.fromLTRB(0, 9, 0, 5), child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Directionality(textDirection: TextDirection.ltr, child: Text("340", style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk)))]))]));
  }
}
