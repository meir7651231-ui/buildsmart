// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "input" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/input-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// QtyStepperBox — seam:fields
class ForgeQtyStepperBox extends StatelessWidget {
  const ForgeQtyStepperBox({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(11)), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 8, children: [Text("+", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Container(height: 44, constraints: const BoxConstraints(minWidth: 46), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(10)), child: Text("4", textAlign: TextAlign.center, style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontWeight: FontWeight.w600))), Text("−", style: TextStyle(color: skin.ink, fontFamily: fonts.he))]));
  }
}
