// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "card" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/card-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// GlassCard — seam:fields
class ForgeGlassCard extends StatelessWidget {
  const ForgeGlassCard({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return ClipRRect(borderRadius: BorderRadius.circular(16), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), child: Container(constraints: const BoxConstraints(minHeight: 130), decoration: BoxDecoration(color: const Color(0x0FFFFFFF), border: Border.all(color: const Color(0x29FFFFFF)), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0x66000000), offset: const Offset(0, 12), blurRadius: 51, spreadRadius: 0)]), child: Stack(clipBehavior: Clip.none, children: [Padding(padding: const EdgeInsets.fromLTRB(18, 18, 18, 18), child: Container(margin: const EdgeInsets.fromLTRB(0, 16, 0, 0), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 14, fontWeight: FontWeight.w600)), Container(margin: const EdgeInsets.fromLTRB(0, 3, 0, 0), child: Text("Meta", style: TextStyle(color: skin.mut, fontSize: 11.5, fontFamily: fonts.he)))]))), Positioned(top: 14, left: 14, child: Text("GLASS", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 8, letterSpacing: 1)))]))));
  }
}
