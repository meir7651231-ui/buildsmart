// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "text" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/text-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// LinkRow — seam:collection
class ForgeLinkRow extends StatelessWidget {
  const ForgeLinkRow({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 24), decoration: BoxDecoration(color: skin.surface, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("שורה עם", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Text("קישור מודגש", style: TextStyle(color: theme.aHi)), Text("וגם", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Text("קו תחתון", style: TextStyle(color: theme.aHi)), Text("בתוך פסקה — כל מצב נגזר מ-var(--a).", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Row(mainAxisSize: MainAxisSize.min, spacing: 8, children: [Row(mainAxisSize: MainAxisSize.min, spacing: 10, children: [Text("Label"), Text("·"), Text("Label"), Text("·"), Text("Meta")])])]));
  }
}
