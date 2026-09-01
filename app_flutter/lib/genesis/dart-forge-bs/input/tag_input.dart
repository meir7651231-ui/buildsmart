// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "input" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/input-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// TagInput — seam:collection
class ForgeTagInput extends StatelessWidget {
  const ForgeTagInput({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(10, 7, 10, 7), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 7, children: [Container(padding: const EdgeInsets.fromLTRB(10, 4, 6, 4), decoration: BoxDecoration(color: theme.a, border: Border.all(color: theme.a), borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 6, children: [Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Text("×")])), Container(padding: const EdgeInsets.fromLTRB(10, 4, 6, 4), decoration: BoxDecoration(color: theme.a, border: Border.all(color: theme.a), borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 6, children: [Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Text("×")])), Container(constraints: const BoxConstraints(minHeight: 44), child: Text("Add…", style: TextStyle(color: skin.faint, fontFamily: fonts.he, fontSize: 13)))]));
  }
}
