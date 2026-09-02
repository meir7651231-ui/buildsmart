// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "header" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/header-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// HeroHeader — seam:title+cta
class ForgeHeroHeader extends StatelessWidget {
  const ForgeHeroHeader({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(constraints: const BoxConstraints(minHeight: 170), padding: const EdgeInsets.fromLTRB(20, 26, 20, 26), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.raised, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Container(margin: const EdgeInsets.fromLTRB(0, 0, 0, 8), child: Text("EYEBROW", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 2))), Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.serifHe, fontSize: 30, fontWeight: FontWeight.w700, letterSpacing: -0.30, height: 1.05)), Container(margin: const EdgeInsets.fromLTRB(0, 7, 0, 0), child: Text("Meta · the one sentence that frames everything below, set larger and calmer.", style: TextStyle(color: skin.mut, fontSize: 13.5, height: 1.45, fontFamily: fonts.he))), Container(margin: const EdgeInsets.fromLTRB(0, 16, 0, 0), child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 10, children: [Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(15, 9, 15, 9), decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(11)), child: Text("Action", style: TextStyle(color: const Color(0xFF0A0A0C), fontFamily: fonts.he, fontSize: 12, fontWeight: FontWeight.w600))), Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(15, 9, 15, 9), decoration: BoxDecoration(border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: Text("Action", style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 12, fontWeight: FontWeight.w600)))]))]));
  }
}
