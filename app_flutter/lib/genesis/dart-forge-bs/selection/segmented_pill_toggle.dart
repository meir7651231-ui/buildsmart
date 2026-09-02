// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "selection" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/selection-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// SegmentedPillToggle — seam:exclusive
class ForgeSegmentedPillToggle extends StatelessWidget {
  const ForgeSegmentedPillToggle({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(constraints: const BoxConstraints(minHeight: 130), padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(15)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 11, children: [Container(margin: const EdgeInsets.fromLTRB(0, 0, 0, 0), child: Container(decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: Stack(clipBehavior: Clip.none, children: [Padding(padding: const EdgeInsets.fromLTRB(3, 3, 3, 3), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(16, 8, 16, 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)), child: Text("Label", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 11, fontWeight: FontWeight.w600))), Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(16, 8, 16, 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)), child: Text("Label", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 11, fontWeight: FontWeight.w600)))])), Positioned(top: 3, bottom: 3, child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: theme.gl, offset: const Offset(0, 2), blurRadius: 8, spreadRadius: 0)])))])))]));
  }
}
