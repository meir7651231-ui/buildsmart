// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "status" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/status-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// StatusDotChip — seam:fields
class ForgeStatusDotChip extends StatelessWidget {
  const ForgeStatusDotChip({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2), child: Row(mainAxisSize: MainAxisSize.min, spacing: 8, children: [Container(padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 11), decoration: BoxDecoration(borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.min, spacing: 6, children: [const SizedBox.shrink(), Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.he))])), Container(padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 11), decoration: BoxDecoration(borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.min, spacing: 6, children: [const SizedBox.shrink(), Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.he))]))]));
  }
}
