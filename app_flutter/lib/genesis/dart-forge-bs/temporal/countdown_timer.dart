// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "temporal" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/temporal-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// CountdownTimer — seam:fields
class ForgeCountdownTimer extends StatelessWidget {
  const ForgeCountdownTimer({super.key});
  @override
  Widget build(BuildContext context) {
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), child: Container(padding: const EdgeInsets.fromLTRB(0, 8, 0, 8), child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, spacing: 8, children: [Container(constraints: const BoxConstraints(minWidth: 56), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 6, children: [Text("02", style: TextStyle(fontFamily: fonts.grotesk, fontFeatures: const [FontFeature.tabularFigures()])), Text("days")])), Text(":"), Container(constraints: const BoxConstraints(minWidth: 56), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 6, children: [Text("08", style: TextStyle(fontFamily: fonts.grotesk, fontFeatures: const [FontFeature.tabularFigures()])), Text("hrs")])), Text(":"), Container(constraints: const BoxConstraints(minWidth: 56), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 6, children: [Text("45", style: TextStyle(fontFamily: fonts.grotesk, fontFeatures: const [FontFeature.tabularFigures()])), Text("min")])), Text(":"), Container(constraints: const BoxConstraints(minWidth: 56), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 6, children: [Text("09", style: TextStyle(fontFamily: fonts.grotesk, fontFeatures: const [FontFeature.tabularFigures()])), Text("sec")]))])));
  }
}
