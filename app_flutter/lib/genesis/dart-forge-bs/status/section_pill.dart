// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "status" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/status-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// SectionPill — seam:fields
class ForgeSectionPill extends StatelessWidget {
  const ForgeSectionPill({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(2, 8, 2, 8), child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 8, children: [Container(padding: const EdgeInsets.fromLTRB(11, 6, 11, 6), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Text("Label", style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontSize: 9.5, fontWeight: FontWeight.w600))), Container(padding: const EdgeInsets.fromLTRB(11, 6, 11, 6), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Text("Label", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 9.5, fontWeight: FontWeight.w600)))]));
  }
}
