// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "header" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/header-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// TitledSection — seam:title+actions
class ForgeTitledSection extends StatelessWidget {
  const ForgeTitledSection({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(20, 20, 20, 20), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.serifHe, fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: 01, height: 1.05)), Container(margin: const EdgeInsets.fromLTRB(0, 7, 0, 0), child: Text("Meta", style: TextStyle(color: skin.mut, fontSize: 12.5, height: 1.45, fontFamily: fonts.he))), Container(margin: const EdgeInsets.fromLTRB(0, 14, 0, 0), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 8, children: [Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(15, 9, 15, 9), decoration: BoxDecoration(color: skin.raised, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: Text("Action", style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 12, fontWeight: FontWeight.w600))), Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(15, 9, 15, 9), decoration: BoxDecoration(border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: Text("Action", style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 12, fontWeight: FontWeight.w600)))]))]));
  }
}
