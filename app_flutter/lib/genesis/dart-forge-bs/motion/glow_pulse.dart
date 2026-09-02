// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "motion" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/motion-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// GlowPulse — seam:fields
class ForgeGlowPulse extends StatelessWidget {
  const ForgeGlowPulse({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    return Container(height: 150, decoration: BoxDecoration(color: skin.sunken), child: Stack(clipBehavior: Clip.none, children: [Positioned.fill(child: Container(width: 56, height: 56, decoration: BoxDecoration(color: theme.aHi, borderRadius: BorderRadius.circular(50), boxShadow: [BoxShadow(color: theme.gl, offset: const Offset(0, 0), blurRadius: 40, spreadRadius: 0)])))]));
  }
}
