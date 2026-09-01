// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "status" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/status-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';

/// 6 atoms — seam:fields
class Forge6Atoms extends StatelessWidget {
  const Forge6Atoms({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, spacing: 14, children: [Row(mainAxisSize: MainAxisSize.min, spacing: 8, children: [const SizedBox.shrink()]), Text("inherit StatusDot →"), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Dot"), Text("LiveDot"), Text("StatusDotChip"), Text("MaterialDots"), Text("DotsLoader"), Text("BadgedIcon")])]);
  }
}
