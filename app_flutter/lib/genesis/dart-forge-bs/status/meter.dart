// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "status" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/status-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// Meter — seam:fields
class ForgeMeter extends StatelessWidget {
  const ForgeMeter({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(0, 6, 0, 6), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 7, children: [Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [Text("Label", style: TextStyle(color: skin.mut, fontSize: 11, fontWeight: FontWeight.w600, fontFamily: fonts.he)), Text("94%", style: TextStyle(color: skin.ok, fontFamily: fonts.grotesk, fontSize: 12, fontWeight: FontWeight.w700))]), Container(height: 8, decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair2), borderRadius: BorderRadius.circular(999)), child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.ok, skin.ok], begin: Alignment.centerLeft, end: Alignment.centerRight), borderRadius: BorderRadius.circular(999))))]));
  }
}
