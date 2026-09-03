// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "card" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/card-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// RevealCard — seam:fields
class ForgeRevealCard extends StatelessWidget {
  const ForgeRevealCard({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(height: 120, decoration: BoxDecoration(color: skin.surface, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(15)), child: Center(widthFactor: 1.0, child: SizedBox(width: double.infinity, child: Stack(clipBehavior: Clip.none, children: [Text("Label", style: TextStyle(color: skin.ink, fontWeight: FontWeight.w600, fontFamily: fonts.he)), Positioned.fill(child: const SizedBox.shrink())]))));
  }
}
