// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "selection" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/selection-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// 14 atoms — seam:series
class Forge14Atoms extends StatelessWidget {
  const Forge14Atoms({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(15)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 11, children: [Row(mainAxisSize: MainAxisSize.min, spacing: 14, children: [Text("Label", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 11, fontWeight: FontWeight.w600)), Text("inherit DsChip →"), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Pill"), Text("BadgePill"), Text("ValueChip"), Text("PriceChip"), Text("NameChip"), Text("AttributeChip"), Text("StageChip"), Text("SectionPill"), Text("SummaryChip"), Text("ProjectChip"), Text("IntelPill"), Text("StorePill"), Text("ScoreBandChip"), Text("PickerOptionChip")])])]));
  }
}
