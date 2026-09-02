// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "selection" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/selection-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// RatingBars — seam:value
class ForgeRatingBars extends StatelessWidget {
  const ForgeRatingBars({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(constraints: const BoxConstraints(minHeight: 130), padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(15)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 11, children: [Container(margin: const EdgeInsets.fromLTRB(0, 0, 0, 0), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Container(height: 34, child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.end, spacing: 5, children: [FractionallySizedBox(heightFactor: 0.400, alignment: Alignment.centerRight, child: Container(width: 16, decoration: BoxDecoration(color: skin.raised2, borderRadius: BorderRadius.circular(3)))), FractionallySizedBox(heightFactor: 0.580, alignment: Alignment.centerRight, child: Container(width: 16, decoration: BoxDecoration(color: skin.raised2, borderRadius: BorderRadius.circular(3)))), FractionallySizedBox(heightFactor: 0.720, alignment: Alignment.centerRight, child: Container(width: 16, decoration: BoxDecoration(color: skin.raised2, borderRadius: BorderRadius.circular(3)))), FractionallySizedBox(heightFactor: 0.860, alignment: Alignment.centerRight, child: Container(width: 16, decoration: BoxDecoration(color: skin.raised2, borderRadius: BorderRadius.circular(3)))), Container(width: 16, decoration: BoxDecoration(color: skin.raised2, borderRadius: BorderRadius.circular(3)))])), Directionality(textDirection: TextDirection.ltr, child: Container(margin: const EdgeInsets.fromLTRB(0, 10, 0, 0), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Value", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 10)), Text("3", style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontSize: 10)), Text("/ 5", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 10))])))]))]));
  }
}
