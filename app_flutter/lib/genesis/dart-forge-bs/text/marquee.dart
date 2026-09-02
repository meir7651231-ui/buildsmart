// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "text" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/text-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// Marquee — seam:fields
class ForgeMarquee extends StatelessWidget {
  const ForgeMarquee({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(0, 0, 0, 0), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Container(padding: const EdgeInsets.fromLTRB(0, 12, 0, 12), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Label ·", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Text("Pure", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Text("· Meta", style: TextStyle(color: skin.ink, fontFamily: fonts.he))]), Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Type ·", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Text("Scale", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Text("· Voice", style: TextStyle(color: skin.ink, fontFamily: fonts.he))]), Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Label ·", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Text("Pure", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Text("· Meta", style: TextStyle(color: skin.ink, fontFamily: fonts.he))]), Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Type ·", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Text("Scale", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Text("· Voice", style: TextStyle(color: skin.ink, fontFamily: fonts.he))])])));
  }
}
