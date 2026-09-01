// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "temporal" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/temporal-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// MetaTicker — seam:fields
class ForgeMetaTicker extends StatelessWidget {
  const ForgeMetaTicker({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Container(decoration: BoxDecoration(color: skin.sunken), child: const SizedBox.shrink()), Container(padding: const EdgeInsets.fromLTRB(16, 12, 16, 16), child: Text("Meta ticker — Label · Value pairs streaming, one row, tabular. Reduced-motion parks it.", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 11, fontFeatures: const [FontFeature.tabularFigures()])))]);
  }
}
