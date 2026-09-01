// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "status" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/status-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// 9 atoms — seam:fields
class Forge9Atoms extends StatelessWidget {
  const Forge9Atoms({super.key});
  @override
  Widget build(BuildContext context) {
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Row(mainAxisSize: MainAxisSize.min, spacing: 14, children: [Text("Label", style: TextStyle(fontFamily: fonts.grotesk, fontSize: 10.5, fontWeight: FontWeight.w700)), Text("inherit StatusChip →"), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Pill"), Text("BadgePill"), Text("CaPill"), Text("StorePill"), Text("IntelPill"), Text("RewardsHubPill"), Text("SectionPill"), Text("FilterChipPill"), Text("DraftBadge")])]);
  }
}
