// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "media" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/media-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// AvatarStatus — seam:fields
class ForgeAvatarStatus extends StatelessWidget {
  const ForgeAvatarStatus({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(constraints: const BoxConstraints(minHeight: 88), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 14, children: [Stack(clipBehavior: Clip.none, children: [Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(50)), child: Text("L", style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.grotesk, fontWeight: FontWeight.w700))), Positioned(bottom: -2, right: -2, child: Container(width: 14, height: 14, decoration: BoxDecoration(color: skin.ok, border: Border.all(color: skin.canvas), borderRadius: BorderRadius.circular(50))))]), Stack(clipBehavior: Clip.none, children: [Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(50)), child: Text("L", style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.grotesk, fontWeight: FontWeight.w700))), Positioned(bottom: -2, right: -2, child: Container(width: 14, height: 14, decoration: BoxDecoration(color: skin.warn, border: Border.all(color: skin.canvas), borderRadius: BorderRadius.circular(50))))]), Stack(clipBehavior: Clip.none, children: [Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(50)), child: Text("L", style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.grotesk, fontWeight: FontWeight.w700))), Positioned(bottom: -2, right: -2, child: Container(width: 14, height: 14, decoration: BoxDecoration(color: skin.faint, border: Border.all(color: skin.canvas), borderRadius: BorderRadius.circular(50))))])]));
  }
}
