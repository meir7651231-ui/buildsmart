// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "feedback" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/feedback-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// 4 atoms — seam:fields
class Forge4Atoms extends StatelessWidget {
  const Forge4Atoms({super.key});
  @override
  Widget build(BuildContext context) {
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Row(mainAxisSize: MainAxisSize.min, spacing: 14, children: [Text("9", style: TextStyle(color: const Color(0xFFFFFFFF), fontFamily: fonts.grotesk, fontSize: 9, fontWeight: FontWeight.w700)), Text("inherit CountBadge →"), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("CatalogCountBadge"), Text("ManagerDashboardCountBadge"), Text("NotifyBadge"), Text("ZoomHintBadge")])]);
  }
}
