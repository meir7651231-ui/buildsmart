// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "status" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/status-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// HierarchyChipPill — seam:fields
class ForgeHierarchyChipPill extends StatelessWidget {
  const ForgeHierarchyChipPill({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(2, 8, 2, 8), child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 8, children: [Directionality(textDirection: TextDirection.ltr, child: Container(constraints: const BoxConstraints(minHeight: 26), padding: const EdgeInsets.fromLTRB(11, 5, 11, 5), decoration: BoxDecoration(borderRadius: BorderRadius.circular(999)), child: Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontSize: 10.5, fontWeight: FontWeight.w700, height: 1)))), Directionality(textDirection: TextDirection.ltr, child: Container(constraints: const BoxConstraints(minHeight: 26), padding: const EdgeInsets.fromLTRB(11, 5, 11, 5), decoration: BoxDecoration(borderRadius: BorderRadius.circular(7)), child: Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontSize: 10.5, fontWeight: FontWeight.w700, height: 1))))]));
  }
}
