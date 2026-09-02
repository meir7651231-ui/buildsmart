// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "motion" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/motion-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// ParallaxTilt — seam:fields
class ForgeParallaxTilt extends StatelessWidget {
  const ForgeParallaxTilt({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    return Container(height: 150, decoration: BoxDecoration(color: skin.sunken), child: Stack(clipBehavior: Clip.none, children: [Positioned.fill(child: Center(widthFactor: 1.0, heightFactor: 1.0, child: Container(width: 120, height: 78, decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.raised2, skin.surface], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: const Color(0xFF000000), offset: const Offset(0, 20), blurRadius: 40, spreadRadius: -18)]), child: Stack(clipBehavior: Clip.none, children: [Positioned.fill(child: Opacity(opacity: 0.9, child: Container(decoration: BoxDecoration(gradient: RadialGradient(center: Alignment.center, radius: 0.50, colors: [theme.gl, skin.sunken], stops: [0.0, 0.60]), borderRadius: BorderRadius.circular(12)))))]))))]));
  }
}
