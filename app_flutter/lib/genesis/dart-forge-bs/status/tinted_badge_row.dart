// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "status" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/status-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// TintedBadgeRow — seam:fields
class ForgeTintedBadgeRow extends StatelessWidget {
  const ForgeTintedBadgeRow({super.key});
  @override
  Widget build(BuildContext context) {
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2), child: Row(mainAxisSize: MainAxisSize.min, spacing: 8, children: [Text("Label 3", style: TextStyle(fontFamily: fonts.grotesk, fontSize: 9.5, fontWeight: FontWeight.w700)), Text("Label 12", style: TextStyle(fontFamily: fonts.grotesk, fontSize: 9.5, fontWeight: FontWeight.w700)), Text("Label 99+", style: TextStyle(fontFamily: fonts.grotesk, fontSize: 9.5, fontWeight: FontWeight.w700))]));
  }
}
