// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "header" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/header-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// WizardHeader — seam:progress
class ForgeWizardHeader extends StatelessWidget {
  const ForgeWizardHeader({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(22, 20, 22, 20), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Container(margin: const EdgeInsets.fromLTRB(0, 0, 0, 12), child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, spacing: 12, children: [Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Step", style: TextStyle(color: skin.mut, fontFamily: fonts.he)), Text("2", style: TextStyle(color: skin.mut, fontFamily: fonts.he)), Text("of 5", style: TextStyle(color: skin.mut, fontFamily: fonts.he))]), Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 7, children: [const SizedBox.shrink(), const SizedBox.shrink(), const SizedBox.shrink(), const SizedBox.shrink(), const SizedBox.shrink()])])), Container(height: 6, decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair2), borderRadius: BorderRadius.circular(999)), child: const SizedBox.shrink()), Container(margin: const EdgeInsets.fromLTRB(0, 14, 0, 0), child: Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.serifHe, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: 01, height: 1.05))), Container(margin: const EdgeInsets.fromLTRB(0, 7, 0, 0), child: Text("Meta", style: TextStyle(color: skin.mut, fontSize: 12.5, height: 1.45, fontFamily: fonts.he)))]));
  }
}
