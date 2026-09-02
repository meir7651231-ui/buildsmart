// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "card" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/card-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// SummaryStatStrip — seam:collection
class ForgeSummaryStatStrip extends StatelessWidget {
  const ForgeSummaryStatStrip({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(decoration: BoxDecoration(color: skin.surface, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(14)), child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, children: [Expanded(child: Container(padding: const EdgeInsets.fromLTRB(14, 13, 14, 13), decoration: BoxDecoration(border: Border(right: BorderSide(color: skin.hair, width: 1))), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Label", style: TextStyle(color: skin.mut, fontSize: 10, fontWeight: FontWeight.w600, fontFamily: fonts.he)), Directionality(textDirection: TextDirection.ltr, child: Text("248", style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontSize: 19, fontWeight: FontWeight.w700)))]))), Expanded(child: Container(padding: const EdgeInsets.fromLTRB(14, 13, 14, 13), decoration: BoxDecoration(border: Border(right: BorderSide(color: skin.hair, width: 1))), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Label", style: TextStyle(color: skin.mut, fontSize: 10, fontWeight: FontWeight.w600, fontFamily: fonts.he)), Directionality(textDirection: TextDirection.ltr, child: Text("92%", style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontSize: 19, fontWeight: FontWeight.w700)))]))), Expanded(child: Container(padding: const EdgeInsets.fromLTRB(14, 13, 14, 13), decoration: BoxDecoration(border: Border(right: BorderSide(color: skin.hair, width: 1))), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Label", style: TextStyle(color: skin.mut, fontSize: 10, fontWeight: FontWeight.w600, fontFamily: fonts.he)), Directionality(textDirection: TextDirection.ltr, child: Text("1,024", style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontSize: 19, fontWeight: FontWeight.w700)))]))), Expanded(child: Container(padding: const EdgeInsets.fromLTRB(14, 13, 14, 13), decoration: BoxDecoration(border: Border(right: BorderSide(color: skin.hair, width: 1))), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Label", style: TextStyle(color: skin.mut, fontSize: 10, fontWeight: FontWeight.w600, fontFamily: fonts.he)), Directionality(textDirection: TextDirection.ltr, child: Text("14", style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontSize: 19, fontWeight: FontWeight.w700)))])))]));
  }
}
