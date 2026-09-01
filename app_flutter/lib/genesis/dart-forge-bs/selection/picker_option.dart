// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "selection" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/selection-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// PickerOption — seam:group
class ForgePickerOption extends StatelessWidget {
  const ForgePickerOption({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(15)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 2, children: [Row(mainAxisSize: MainAxisSize.min, spacing: 11, children: [Container(decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.ink), borderRadius: BorderRadius.circular(50))), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 13)), Text("248", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 11))])]), Row(mainAxisSize: MainAxisSize.min, spacing: 11, children: [Container(decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.ink), borderRadius: BorderRadius.circular(50))), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 13)), Text("1,024", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 11))])]), Row(mainAxisSize: MainAxisSize.min, spacing: 11, children: [Container(decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.ink), borderRadius: BorderRadius.circular(50))), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 13)), Text("—", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 11))])])]));
  }
}
