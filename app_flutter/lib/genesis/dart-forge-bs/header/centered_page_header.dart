// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "header" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/header-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// CenteredPageHeader — seam:title
class ForgeCenteredPageHeader extends StatelessWidget {
  const ForgeCenteredPageHeader({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 22), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Section", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 10, fontWeight: FontWeight.w600)), Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.serifHe, fontWeight: FontWeight.w700)), Text("Meta", style: TextStyle(color: skin.mut, fontSize: 12.5))]));
  }
}
