// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "action" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/action-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// FabMenu — seam:zero
class ForgeFabMenu extends StatelessWidget {
  const ForgeFabMenu({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return SizedBox(width: double.infinity, child: Container(padding: const EdgeInsets.fromLTRB(12, 12, 12, 12), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: const Color(0x73E6B84F)), borderRadius: BorderRadius.circular(11)), child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, spacing: 8, children: [Text("FabMenu", style: TextStyle(color: skin.faint, fontFamily: fonts.he)), Text("ZERO · no seam", style: TextStyle(color: skin.warn, fontFamily: fonts.grotesk, fontSize: 9, letterSpacing: 1))])));
  }
}
