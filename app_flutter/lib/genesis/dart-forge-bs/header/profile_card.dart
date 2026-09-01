// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "header" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/header-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// ProfileCard — seam:avatar+meta
class ForgeProfileCard extends StatelessWidget {
  const ForgeProfileCard({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 22), decoration: BoxDecoration(color: skin.surface, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Container(decoration: BoxDecoration(color: theme.aHi, borderRadius: BorderRadius.circular(50)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [const SizedBox.shrink(), Text("L", style: TextStyle(color: skin.ink, fontFamily: fonts.he))])), Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.serifHe, fontSize: 18, fontWeight: FontWeight.w700)), Row(mainAxisSize: MainAxisSize.min, spacing: 10, children: [Text("Meta")]), Text("Action", style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 12, fontWeight: FontWeight.w600))]));
  }
}
