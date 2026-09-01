// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "feedback" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/feedback-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// 6 atoms — seam:fields
class Forge6Atoms extends StatelessWidget {
  const Forge6Atoms({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 14, children: [const SizedBox.shrink(), Text("inherit SlideSheet →", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 9)), Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 6, children: [Container(padding: const EdgeInsets.fromLTRB(9, 4, 9, 4), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Text("SheetScaffold", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 10))), Container(padding: const EdgeInsets.fromLTRB(9, 4, 9, 4), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Text("StoreSheetScaffold", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 10))), Container(padding: const EdgeInsets.fromLTRB(9, 4, 9, 4), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Text("SnoozeSheet", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 10))), Container(padding: const EdgeInsets.fromLTRB(9, 4, 9, 4), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Text("SichaSheet", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 10))), Container(padding: const EdgeInsets.fromLTRB(9, 4, 9, 4), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Text("SheetTile", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 10))), Container(padding: const EdgeInsets.fromLTRB(9, 4, 9, 4), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Text("SheetStatTile", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 10)))])]);
  }
}
