// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "selection" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/selection-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// DsChip — seam:series
class ForgeDsChip extends StatelessWidget {
  const ForgeDsChip({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(15)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 11, children: [Row(mainAxisSize: MainAxisSize.min, spacing: 8, children: [Text("Label", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 11, fontWeight: FontWeight.w600)), Text("Label", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 11, fontWeight: FontWeight.w600)), Container(padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 9), decoration: BoxDecoration(borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.min, spacing: 5, children: [const SizedBox.shrink(), Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.he))])), Text("Label", style: TextStyle(fontFamily: fonts.grotesk, fontSize: 10, fontWeight: FontWeight.w700)), Text("Label", style: TextStyle(fontFamily: fonts.grotesk, fontSize: 10, fontWeight: FontWeight.w700)), Text("Value 248", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 11, fontWeight: FontWeight.w600))])]));
  }
}
