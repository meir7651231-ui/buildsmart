// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "motion" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/motion-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// GenerativeCanvas — seam:fields
class ForgeGenerativeCanvas extends StatelessWidget {
  const ForgeGenerativeCanvas({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(height: 150, decoration: BoxDecoration(color: skin.sunken), child: Stack(clipBehavior: Clip.none, children: [Positioned(top: 10, right: 10, child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 6, children: [Container(width: 7, height: 7, decoration: BoxDecoration(color: skin.ok, borderRadius: BorderRadius.circular(50), boxShadow: [BoxShadow(color: skin.ok, offset: const Offset(0, 0), blurRadius: 9, spreadRadius: 0)])), Text("Organism", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 8.5, letterSpacing: 1.36))])), Positioned.fill(child: SizedBox(width: double.infinity, child: const SizedBox.shrink()))]));
  }
}
