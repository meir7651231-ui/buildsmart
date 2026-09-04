// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "text" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/text-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// Marquee — seam:fields
class ForgeMarquee extends StatelessWidget {
  const ForgeMarquee({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(0, 0, 0, 0), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Container(padding: const EdgeInsets.fromLTRB(0, 12, 0, 12), child: Directionality(textDirection: TextDirection.ltr, child: Container(margin: const EdgeInsets.fromLTRB(26, 0, 26, 0), child: Text.rich(TextSpan(children: [WidgetSpan(alignment: PlaceholderAlignment.middle, child: Directionality(textDirection: TextDirection.ltr, child: Text.rich(TextSpan(children: [TextSpan(text: "LABEL · ", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 12, letterSpacing: 3)), TextSpan(text: "PURE", style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontSize: 12, letterSpacing: 3)), TextSpan(text: " · META", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 12, letterSpacing: 3))])))), WidgetSpan(alignment: PlaceholderAlignment.middle, child: Directionality(textDirection: TextDirection.ltr, child: Text.rich(TextSpan(children: [TextSpan(text: "TYPE · ", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 12, letterSpacing: 3)), TextSpan(text: "SCALE", style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontSize: 12, letterSpacing: 3)), TextSpan(text: " · VOICE", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 12, letterSpacing: 3))])))), WidgetSpan(alignment: PlaceholderAlignment.middle, child: Directionality(textDirection: TextDirection.ltr, child: Text.rich(TextSpan(children: [TextSpan(text: "LABEL · ", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 12, letterSpacing: 3)), TextSpan(text: "PURE", style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontSize: 12, letterSpacing: 3)), TextSpan(text: " · META", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 12, letterSpacing: 3))])))), WidgetSpan(alignment: PlaceholderAlignment.middle, child: Directionality(textDirection: TextDirection.ltr, child: Text.rich(TextSpan(children: [TextSpan(text: "TYPE · ", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 12, letterSpacing: 3)), TextSpan(text: "SCALE", style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontSize: 12, letterSpacing: 3)), TextSpan(text: " · VOICE", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 12, letterSpacing: 3))]))))]))))));
  }
}
