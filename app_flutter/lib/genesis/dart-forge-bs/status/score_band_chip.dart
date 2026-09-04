// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "status" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/status-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// ScoreBandChip — seam:fields
class ForgeScoreBandChip extends StatelessWidget {
  const ForgeScoreBandChip({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(4, 14, 4, 4), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 10, children: [Container(height: 20, child: Stack(clipBehavior: Clip.none, children: [Positioned(top: -16, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [Directionality(textDirection: TextDirection.ltr, child: Text("76", style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontSize: 11, fontWeight: FontWeight.w700))), Container(margin: const EdgeInsets.fromLTRB(0, 2, 0, 0), decoration: BoxDecoration(border: Border(top: BorderSide(color: skin.ink, width: 7))))]))])), Container(height: 9, decoration: BoxDecoration(borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, children: [Expanded(flex: 40, child: Container(decoration: BoxDecoration(color: skin.err.withValues(alpha: 0.780)))), Expanded(flex: 30, child: Container(decoration: BoxDecoration(color: skin.warn.withValues(alpha: 0.780)))), Expanded(flex: 30, child: Container(decoration: BoxDecoration(color: skin.ok.withValues(alpha: 0.820))))])), SizedBox(width: double.infinity, child: Directionality(textDirection: TextDirection.ltr, child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [Text("0", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 8.5)), Text("40", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 8.5)), Text("70", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 8.5)), Text("100", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 8.5))])))]));
  }
}
