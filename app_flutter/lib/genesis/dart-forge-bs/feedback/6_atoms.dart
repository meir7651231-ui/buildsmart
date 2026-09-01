// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "feedback" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/feedback-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';

/// 6 atoms — seam:fields
class Forge6Atoms extends StatelessWidget {
  const Forge6Atoms({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 14, children: [const SizedBox.shrink(), Text("inherit SlideSheet →"), Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("SheetScaffold"), Text("StoreSheetScaffold"), Text("SnoozeSheet"), Text("SichaSheet"), Text("SheetTile"), Text("SheetStatTile")])]);
  }
}
