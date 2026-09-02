// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "temporal" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/temporal-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// CountdownTimer — seam:fields
class ForgeCountdownTimer extends StatelessWidget {
  const ForgeCountdownTimer({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), child: Container(padding: const EdgeInsets.fromLTRB(0, 8, 0, 8), child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, spacing: 8, children: [Container(constraints: const BoxConstraints(minWidth: 56), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 6, children: [Text("02", style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontFeatures: const [FontFeature.tabularFigures()])), Text("days", style: TextStyle(color: skin.ink, fontFamily: fonts.he))])), Container(padding: const EdgeInsets.fromLTRB(0, 12, 0, 0), child: Text(":", style: TextStyle(color: skin.faint, fontSize: 30, fontFamily: fonts.he))), Container(constraints: const BoxConstraints(minWidth: 56), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 6, children: [Text("08", style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontFeatures: const [FontFeature.tabularFigures()])), Text("hrs", style: TextStyle(color: skin.ink, fontFamily: fonts.he))])), Container(padding: const EdgeInsets.fromLTRB(0, 12, 0, 0), child: Text(":", style: TextStyle(color: skin.faint, fontSize: 30, fontFamily: fonts.he))), Container(constraints: const BoxConstraints(minWidth: 56), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 6, children: [Text("45", style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontFeatures: const [FontFeature.tabularFigures()])), Text("min", style: TextStyle(color: skin.ink, fontFamily: fonts.he))])), Container(padding: const EdgeInsets.fromLTRB(0, 12, 0, 0), child: Text(":", style: TextStyle(color: skin.faint, fontSize: 30, fontFamily: fonts.he))), Container(constraints: const BoxConstraints(minWidth: 56), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 6, children: [Text("09", style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontFeatures: const [FontFeature.tabularFigures()])), Text("sec", style: TextStyle(color: skin.ink, fontFamily: fonts.he))]))])));
  }
}
