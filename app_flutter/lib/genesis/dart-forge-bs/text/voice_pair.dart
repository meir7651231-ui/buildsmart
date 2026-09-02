// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "text" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/text-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// VoicePair — seam:collection
class ForgeVoicePair extends StatelessWidget {
  const ForgeVoicePair({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(decoration: BoxDecoration(color: skin.hair, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 1, children: [Container(padding: const EdgeInsets.fromLTRB(24, 24, 24, 24), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Directionality(textDirection: TextDirection.ltr, child: Text("LATIN · FRAUNCES", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 9, letterSpacing: 2))), const SizedBox(height: 14), Directionality(textDirection: TextDirection.ltr, child: Text("The quiet system", style: TextStyle(color: skin.ink, fontFamily: fonts.serif, fontSize: 26, fontWeight: FontWeight.w600, letterSpacing: -0.52, height: 1.08))), const SizedBox(height: 12), Text("A serif display face carries the Latin headline — high contrast, optical sizing, an editorial register that reads as considered rather than default.", style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 13, height: 1.65)), const SizedBox(height: 14), Directionality(textDirection: TextDirection.ltr, child: Text("Fraunces · opsz 9–144", style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontSize: 10, letterSpacing: 0.5)))])), Container(padding: const EdgeInsets.fromLTRB(24, 24, 24, 24), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Directionality(textDirection: TextDirection.ltr, child: Text("עברית · FRANK RUHL LIBRE", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 9, letterSpacing: 2))), const SizedBox(height: 14), Text("המערכת השקטה", style: TextStyle(color: skin.ink, fontFamily: fonts.serifHe, fontSize: 26, fontWeight: FontWeight.w700, height: 1.15)), const SizedBox(height: 12), Text("פרנק-רוהל נושא את הכותרת העברית — נגזרת קלאסית, משקל אחד כבד, קול עורכי שקורא כמכוון ולא כברירת-מחדל.", style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 13, height: 1.65)), const SizedBox(height: 14), Directionality(textDirection: TextDirection.ltr, child: Text("Frank Ruhl Libre · 700", style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontSize: 10, letterSpacing: 0.5)))]))]));
  }
}
