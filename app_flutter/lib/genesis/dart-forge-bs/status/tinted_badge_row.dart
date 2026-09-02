// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "status" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/status-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// TintedBadgeRow — seam:fields
class ForgeTintedBadgeRow extends StatelessWidget {
  const ForgeTintedBadgeRow({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(2, 8, 2, 8), child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 8, children: [Container(padding: const EdgeInsets.fromLTRB(8, 3, 8, 3), decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)), child: Text("LABEL 3", style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: 5))), Container(padding: const EdgeInsets.fromLTRB(8, 3, 8, 3), decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)), child: Text("LABEL 12", style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: 5))), Container(padding: const EdgeInsets.fromLTRB(8, 3, 8, 3), decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)), child: Text("LABEL 99+", style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: 5)))]));
  }
}
