// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "card" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/card-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// StripPanelFrame — seam:fields
class ForgeStripPanelFrame extends StatelessWidget {
  const ForgeStripPanelFrame({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(14, 14, 14, 14), decoration: BoxDecoration(border: Border.all(color: theme.a), borderRadius: BorderRadius.circular(16)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 12.5, fontWeight: FontWeight.w600)), Container(margin: const EdgeInsets.fromLTRB(0, 3, 0, 0), child: Text("Meta", style: TextStyle(color: skin.mut, fontSize: 11.5, fontFamily: fonts.he)))]));
  }
}
