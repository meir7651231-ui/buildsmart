// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "media" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/media-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// Avatar — seam:series
class ForgeAvatar extends StatelessWidget {
  const ForgeAvatar({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(constraints: const BoxConstraints(minHeight: 88), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 14, children: [Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(0.3)), child: Text("L", style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.grotesk, fontWeight: FontWeight.w700, height: 1))), Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(0.3)), child: Text("L", style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.grotesk, fontWeight: FontWeight.w700, height: 1))), Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(0.3)), child: Text("L", style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.grotesk, fontWeight: FontWeight.w700, height: 1))), Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(0.3)), child: Text("L", style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.grotesk, fontWeight: FontWeight.w700, height: 1)))]));
  }
}
