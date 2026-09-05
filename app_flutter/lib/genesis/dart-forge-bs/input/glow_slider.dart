// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "input" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/input-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// GlowSlider — seam:fields
class ForgeGlowSlider extends StatelessWidget {
  const ForgeGlowSlider({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(4, 14, 4, 6), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Container(constraints: const BoxConstraints(minHeight: 44), child: Align(alignment: Alignment.centerRight, child: Text("58", style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 13)))), const SizedBox(height: 12), Directionality(textDirection: TextDirection.ltr, child: Text("58", textAlign: TextAlign.center, style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11)))]));
  }
}
