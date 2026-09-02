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
    return Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 14, children: [Container(height: 18, constraints: const BoxConstraints(minWidth: 18), padding: const EdgeInsets.fromLTRB(4, 0, 4, 0), decoration: BoxDecoration(color: skin.err, border: Border.all(color: skin.surface, width: 2), borderRadius: BorderRadius.circular(999)), child: Text("9", style: TextStyle(color: const Color(0xFFFFFFFF), fontFamily: fonts.grotesk, fontSize: 9, fontWeight: FontWeight.w700))), Text("INHERIT COUNTBADGE →", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 9, letterSpacing: 1)), Expanded(child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 6, children: [Container(padding: const EdgeInsets.fromLTRB(9, 4, 9, 4), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Text("CatalogCountBadge", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 10))), Container(padding: const EdgeInsets.fromLTRB(9, 4, 9, 4), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Text("ManagerDashboardCountBadge", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 10))), Container(padding: const EdgeInsets.fromLTRB(9, 4, 9, 4), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Text("NotifyBadge", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 10))), Container(padding: const EdgeInsets.fromLTRB(9, 4, 9, 4), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Text("ZoomHintBadge", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 10)))]))]);
  }
}
