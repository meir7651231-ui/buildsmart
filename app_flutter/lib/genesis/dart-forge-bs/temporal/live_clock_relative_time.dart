// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "temporal" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/temporal-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// LiveClock + RelativeTime — seam:fields
class ForgeLiveClockRelativeTime extends StatelessWidget {
  const ForgeLiveClockRelativeTime({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.fromLTRB(0, 12, 0, 12), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Directionality(textDirection: TextDirection.ltr, child: Text("14:32:07", style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontSize: 44, fontWeight: FontWeight.w700, letterSpacing: 0.88, fontFeatures: const [FontFeature.tabularFigures()]))), const SizedBox(height: 4), Directionality(textDirection: TextDirection.ltr, child: Text("Label · Meta", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 11)))])), Directionality(textDirection: TextDirection.ltr, child: Container(margin: const EdgeInsets.fromLTRB(0, 10, 0, 0), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 7, children: [Container(width: 6, height: 6, decoration: BoxDecoration(color: theme.a, borderRadius: BorderRadius.circular(999))), Text("RelativeTime · ", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 10, letterSpacing: 1.20)), Text("META", style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontSize: 10, fontWeight: FontWeight.w700))])))]));
  }
}
