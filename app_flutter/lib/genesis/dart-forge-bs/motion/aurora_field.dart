// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "motion" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/motion-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// AuroraField — seam:fields
class ForgeAuroraField extends StatelessWidget {
  const ForgeAuroraField({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(height: 150, decoration: BoxDecoration(color: skin.sunken), child: SizedBox(width: double.infinity, child: Stack(clipBehavior: Clip.none, children: [Positioned.fill(child: Opacity(opacity: 0.55, child: Container(decoration: BoxDecoration(gradient: SweepGradient(colors: [theme.c2, theme.a, theme.c3, theme.aHi, theme.c2], transform: const GradientRotation(-1.5708)))))), Positioned(top: 10, right: 10, child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 6, children: [Container(width: 7, height: 7, decoration: BoxDecoration(color: skin.ok, borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: skin.ok, offset: const Offset(0, 0), blurRadius: 9, spreadRadius: 0)])), Text("AURORA", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 8.5, letterSpacing: 1.36))]))])));
  }
}
