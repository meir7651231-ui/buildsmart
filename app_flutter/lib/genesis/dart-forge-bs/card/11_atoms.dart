// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "card" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/card-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// 11 atoms — seam:fields
class Forge11Atoms extends StatelessWidget {
  const Forge11Atoms({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    return Row(mainAxisSize: MainAxisSize.min, spacing: 14, children: [Container(padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 6, children: [Text("42")])), Text("inherit StatTile →"), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Stat"), Text("DsStat"), Text("BareStat"), Text("RStat"), Text("SStat"), Text("TodayStat"), Text("IntelStat"), Text("StatBlock"), Text("StatsCard"), Text("WorkerAppStat"), Text("WorkerProfileStat")])]);
  }
}
