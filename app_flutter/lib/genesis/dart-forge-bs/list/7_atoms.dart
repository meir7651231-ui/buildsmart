// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "list" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/list-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// 7 atoms — seam:fields
class Forge7Atoms extends StatelessWidget {
  const Forge7Atoms({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    return Container(decoration: BoxDecoration(color: skin.surface, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(15)), child: Container(padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 15), child: Row(mainAxisSize: MainAxisSize.min, spacing: 12, children: [Text("L"), Row(mainAxisSize: MainAxisSize.min, spacing: 14, children: [Text("inherit ProfileRow →"), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("ContactRow"), Text("SupplierTile"), Text("CustomerRow"), Text("CourierAttendanceTableRow"), Text("SiteRow"), Text("VacationRow"), Text("HomeShellMenuRow")])])])));
  }
}
