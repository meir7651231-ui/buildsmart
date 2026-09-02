// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "header" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/header-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// ProfileCard — seam:avatar+meta
class ForgeProfileCard extends StatelessWidget {
  const ForgeProfileCard({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(24, 24, 24, 24), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 2, children: [Container(width: 64, height: 64, alignment: Alignment.center, decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(20)), child: Stack(clipBehavior: Clip.none, children: [Text("L", style: TextStyle(color: const Color(0xFF0A0A0C), fontFamily: fonts.grotesk, fontSize: 24, fontWeight: FontWeight.w700)), Positioned.fill(child: Container(decoration: BoxDecoration(border: Border.all(color: theme.a.withValues(alpha: 0.45)))))])), Container(margin: const EdgeInsets.fromLTRB(0, 10, 0, 0), child: Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.serifHe, fontSize: 18, fontWeight: FontWeight.w700))), Container(margin: const EdgeInsets.fromLTRB(0, 4, 0, 0), child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, spacing: 10, children: [Text("Meta", style: TextStyle(color: skin.faint, fontFamily: fonts.he))])), Container(constraints: const BoxConstraints(minHeight: 44), margin: const EdgeInsets.fromLTRB(0, 10, 0, 0), padding: const EdgeInsets.fromLTRB(15, 9, 15, 9), decoration: BoxDecoration(border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: Text("Action", style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 12, fontWeight: FontWeight.w600)))]));
  }
}
