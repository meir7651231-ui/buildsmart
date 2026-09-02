// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "media" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/media-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// StoryRing — seam:fields
class ForgeStoryRing extends StatelessWidget {
  const ForgeStoryRing({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(constraints: const BoxConstraints(minHeight: 88), child: Wrap(spacing: 14, runSpacing: 14, crossAxisAlignment: WrapCrossAlignment.center, children: [Container(width: 66, height: 66, alignment: Alignment.center, decoration: BoxDecoration(color: theme.aHi, borderRadius: BorderRadius.circular(50)), child: Stack(clipBehavior: Clip.none, children: [Padding(padding: const EdgeInsets.fromLTRB(3, 3, 3, 3), child: Container(width: 54, height: 54, alignment: Alignment.center, decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(50)), child: Text("L", style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.grotesk, fontSize: 54, fontWeight: FontWeight.w700, height: 1)))), Positioned.fill(child: Container(decoration: BoxDecoration(color: skin.canvas, borderRadius: BorderRadius.circular(50))))])), Container(width: 66, height: 66, alignment: Alignment.center, decoration: BoxDecoration(color: theme.aHi, borderRadius: BorderRadius.circular(50)), child: Stack(clipBehavior: Clip.none, children: [Padding(padding: const EdgeInsets.fromLTRB(3, 3, 3, 3), child: Container(width: 54, height: 54, alignment: Alignment.center, decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.c2, theme.a, theme.c3], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(50)), child: Text("L", style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.grotesk, fontSize: 54, fontWeight: FontWeight.w700, height: 1)))), Positioned.fill(child: Container(decoration: BoxDecoration(color: skin.canvas, borderRadius: BorderRadius.circular(50))))]))]));
  }
}
