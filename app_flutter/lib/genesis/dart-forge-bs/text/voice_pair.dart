// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "text" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/text-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
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
    return Container(decoration: BoxDecoration(color: skin.hair, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 1, children: [Container(padding: const EdgeInsets.fromLTRB(24, 24, 24, 24), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Container(margin: const EdgeInsets.fromLTRB(0, 0, 0, 14), child: Text("Latin · Fraunces", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 9))), Text("The quiet system", style: TextStyle(color: skin.ink, fontFamily: fonts.serif, fontSize: 26, fontWeight: FontWeight.w600)), Container(margin: const EdgeInsets.fromLTRB(0, 12, 0, 0), child: Text("A serif display face carries the Latin headline — high contrast, optical sizing, an editorial register that reads as considered rather than default.", style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 13))), Container(margin: const EdgeInsets.fromLTRB(0, 14, 0, 0), child: Text("Fraunces · opsz 9–144", style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontSize: 10)))])), Container(padding: const EdgeInsets.fromLTRB(24, 24, 24, 24), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Container(margin: const EdgeInsets.fromLTRB(0, 0, 0, 14), child: Text("עברית · Frank Ruhl Libre", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 9))), Text("המערכת השקטה", style: TextStyle(color: skin.ink, fontFamily: fonts.serifHe, fontSize: 26, fontWeight: FontWeight.w700)), Container(margin: const EdgeInsets.fromLTRB(0, 12, 0, 0), child: Text("פרנק-רוהל נושא את הכותרת העברית — נגזרת קלאסית, משקל אחד כבד, קול עורכי שקורא כמכוון ולא כברירת-מחדל.", style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 13))), Container(margin: const EdgeInsets.fromLTRB(0, 14, 0, 0), child: Text("Frank Ruhl Libre · 700", style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontSize: 10)))]))]));
  }
}
