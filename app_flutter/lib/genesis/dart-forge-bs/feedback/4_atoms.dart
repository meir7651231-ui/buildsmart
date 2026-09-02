// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "feedback" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/feedback-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// 4 atoms — seam:fields
class Forge4Atoms extends StatelessWidget {
  const Forge4Atoms({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return SizedBox(width: double.infinity, child: Wrap(spacing: 14, runSpacing: 14, crossAxisAlignment: WrapCrossAlignment.center, children: [Container(height: 18, constraints: const BoxConstraints(minWidth: 18), padding: const EdgeInsets.fromLTRB(4, 0, 4, 0), decoration: BoxDecoration(color: skin.err, border: Border.all(color: skin.surface, width: 2), borderRadius: BorderRadius.circular(999)), child: Center(widthFactor: 1.0, child: Text("9", style: TextStyle(color: const Color(0xFFFFFFFF), fontFamily: fonts.grotesk, fontSize: 9, fontWeight: FontWeight.w700)))), Directionality(textDirection: TextDirection.ltr, child: Text("INHERIT COUNTBADGE →", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 9, letterSpacing: 1))), Expanded(child: Wrap(spacing: 6, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(9, 4, 9, 4), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Text("CatalogCountBadge", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 10)))), Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(9, 4, 9, 4), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Text("ManagerDashboardCountBadge", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 10)))), Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(9, 4, 9, 4), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Text("NotifyBadge", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 10)))), Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(9, 4, 9, 4), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Text("ZoomHintBadge", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 10))))]))]));
  }
}
