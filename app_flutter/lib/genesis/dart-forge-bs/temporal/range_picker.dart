// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "temporal" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/temporal-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';

/// RangePicker — seam:fields
class ForgeRangePicker extends StatelessWidget {
  const ForgeRangePicker({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 3, children: [Text("א"), Text("ב"), Text("ג"), Text("ד"), Text("ה"), Text("ו"), Text("ש")]), const SizedBox.shrink()]));
  }
}
