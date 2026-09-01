// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "composite" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/composite-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

// אייקון-פלייסהולדר ניטרלי (SVG המקורי אינו מתורגם — נשמר כתצורה, לא כפיקסל)
Widget _icon(Color c) => Icon(Icons.circle_outlined, size: 15, color: c);

/// WizardHeader — seam:self
class ForgeWizardHeader extends StatelessWidget {
  const ForgeWizardHeader({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(decoration: BoxDecoration(color: skin.surface, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(18)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18), child: Row(mainAxisSize: MainAxisSize.min, spacing: 12, children: [Row(mainAxisSize: MainAxisSize.min, spacing: 12, children: [Text("2 / 4", style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontSize: 11, fontWeight: FontWeight.w700)), Container(decoration: BoxDecoration(color: skin.raised2, borderRadius: BorderRadius.circular(999)), child: const SizedBox.shrink())])])), Container(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 14, children: [Text("Label", style: TextStyle(fontFamily: fonts.serifHe, fontSize: 16, fontWeight: FontWeight.w700)), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 6, children: [Text("Label", style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 11, fontWeight: FontWeight.w600)), Row(mainAxisSize: MainAxisSize.min, children: [_icon(skin.mut), Text("Value", style: TextStyle(color: skin.faint, fontFamily: fonts.he, fontSize: 13))]), Text("Meta · helper", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 9.5))])])), Container(padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18), child: Row(mainAxisSize: MainAxisSize.min, spacing: 10, children: [Container(padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 18), decoration: BoxDecoration(color: skin.raised, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: Row(mainAxisSize: MainAxisSize.min, spacing: 7, children: [_icon(skin.mut), Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.he))])), const SizedBox.shrink(), Container(padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 18), decoration: BoxDecoration(color: skin.raised, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: Row(mainAxisSize: MainAxisSize.min, spacing: 7, children: [Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), _icon(skin.mut)]))]))]));
  }
}
