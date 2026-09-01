// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "action" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/action-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// FabAction — seam:zero
class ForgeFabAction extends StatelessWidget {
  const ForgeFabAction({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: const Color(0x73E6B84F)), borderRadius: BorderRadius.circular(11)), child: Row(mainAxisSize: MainAxisSize.min, spacing: 8, children: [Text("FabAction"), Text("ZERO · no seam")]));
  }
}
