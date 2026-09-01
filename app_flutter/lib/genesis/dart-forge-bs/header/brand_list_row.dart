// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "header" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/header-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// BrandListRow — seam:mark
class ForgeBrandListRow extends StatelessWidget {
  const ForgeBrandListRow({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 22), decoration: BoxDecoration(color: skin.surface, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Row(mainAxisSize: MainAxisSize.min, spacing: 14, children: [Text("L", style: TextStyle(color: const Color(0xFF0A0A0C), fontFamily: fonts.grotesk, fontSize: 18, fontWeight: FontWeight.w700)), Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.serif, fontSize: 19, fontWeight: FontWeight.w600))]));
  }
}
