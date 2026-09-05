// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "card" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/card-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// FlipCard — seam:fields
class ForgeFlipCard extends StatelessWidget {
  const ForgeFlipCard({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(height: 120, child: SizedBox(width: double.infinity, child: Stack(clipBehavior: Clip.none, children: [Positioned.fill(child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(15)), child: Center(widthFactor: 1.0, heightFactor: 1.0, child: Text("Label", style: TextStyle(color: skin.ink, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: fonts.he))))), Positioned.fill(child: const SizedBox.shrink())])));
  }
}
