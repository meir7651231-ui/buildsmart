// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "list" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/list-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// 2 atoms — seam:fields
class Forge2Atoms extends StatelessWidget {
  const Forge2Atoms({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(15)), child: Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(15, 11, 15, 11), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 12, children: [Container(width: 18, height: 18, decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(6))), Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 14, children: [Text("inherit CheckRow →", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 9)), Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 6, children: [Container(padding: const EdgeInsets.fromLTRB(9, 4, 9, 4), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Text("RegressionPanelCheckRow", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 10))), Container(padding: const EdgeInsets.fromLTRB(9, 4, 9, 4), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Text("FacetRow", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 10)))])])])));
  }
}
