// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "feedback" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/feedback-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// RuleInspectDialog — seam:fields
class ForgeRuleInspectDialog extends StatelessWidget {
  const ForgeRuleInspectDialog({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(18, 18, 18, 18), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.raised, skin.surface], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0x99000000), offset: const Offset(0, 30), blurRadius: 80, spreadRadius: 0)]), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 12, children: [Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.serifHe, fontSize: 16, fontWeight: FontWeight.w700)), Container(padding: const EdgeInsets.fromLTRB(8, 8, 8, 8), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(8)), child: Text("Meta · rule", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 11))), Container(margin: const EdgeInsets.fromLTRB(0, 2, 0, 0), child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, spacing: 9, children: [Container(height: 44, padding: const EdgeInsets.fromLTRB(15, 0, 15, 0), decoration: BoxDecoration(color: skin.raised2, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(10)), child: Text("Action", style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 12.5, fontWeight: FontWeight.w700)))]))]));
  }
}
