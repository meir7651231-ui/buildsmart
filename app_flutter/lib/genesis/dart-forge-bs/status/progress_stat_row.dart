// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "status" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/status-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// ProgressStatRow — seam:fields
class ForgeProgressStatRow extends StatelessWidget {
  const ForgeProgressStatRow({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(0, 6, 0, 6), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Container(margin: const EdgeInsets.fromLTRB(0, 0, 0, 7), child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Text("4 / 6", style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk))])), Container(height: 9, child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 3, children: [const SizedBox.shrink(), const SizedBox.shrink(), const SizedBox.shrink(), const SizedBox.shrink(), const SizedBox.shrink(), const SizedBox.shrink()]))]));
  }
}
