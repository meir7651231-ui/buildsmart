// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "action" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/action-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// StepBtn — seam:fields
class ForgeStepBtn extends StatelessWidget {
  const ForgeStepBtn({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(decoration: BoxDecoration(color: skin.raised, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [Container(width: 38, height: 44, child: Text("−", style: TextStyle(color: skin.ink, fontSize: 17, fontFamily: fonts.he))), Container(constraints: const BoxConstraints(minWidth: 40), child: Text("2", textAlign: TextAlign.center, style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontWeight: FontWeight.w600))), Container(width: 38, height: 44, child: Text("+", style: TextStyle(color: skin.ink, fontSize: 17, fontFamily: fonts.he)))]));
  }
}
