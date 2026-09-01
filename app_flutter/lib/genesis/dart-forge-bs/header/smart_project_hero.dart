// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "header" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/header-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// SmartProjectHero — seam:title
class ForgeSmartProjectHero extends StatelessWidget {
  const ForgeSmartProjectHero({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(26, 24, 26, 24), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.raised, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 16, children: [Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Container(margin: const EdgeInsets.fromLTRB(0, 0, 0, 8), child: Text("Project", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 10, fontWeight: FontWeight.w600))), Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.serifHe, fontSize: 28, fontWeight: FontWeight.w700)), Container(margin: const EdgeInsets.fromLTRB(0, 7, 0, 0), child: Text("Meta", style: TextStyle(color: skin.mut, fontSize: 13.5, fontFamily: fonts.he)))]), Container(margin: const EdgeInsets.fromLTRB(0, 6, 0, 0), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 7, children: [const SizedBox.shrink(), const SizedBox.shrink(), const SizedBox.shrink()]))])]));
  }
}
