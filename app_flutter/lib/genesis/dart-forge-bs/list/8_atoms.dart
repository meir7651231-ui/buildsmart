// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "list" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/list-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// 8 atoms — seam:fields
class Forge8Atoms extends StatelessWidget {
  const Forge8Atoms({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    return Container(decoration: BoxDecoration(color: skin.surface, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(15)), child: Container(padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 15), child: Row(mainAxisSize: MainAxisSize.min, spacing: 12, children: [Text("42"), Row(mainAxisSize: MainAxisSize.min, spacing: 14, children: [Text("inherit KvRow →"), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("KvLine"), Text("FinRow"), Text("ThrRow"), Text("RewardsHubFinRow"), Text("StoreSummaryLine"), Text("WorkerReportsTabKvRow"), Text("DecisionLine"), Text("SpecialtyDerivedRow")])])])));
  }
}
