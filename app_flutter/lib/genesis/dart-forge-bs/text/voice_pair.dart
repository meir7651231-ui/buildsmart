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
    return Container(decoration: BoxDecoration(color: skin.hair, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 1, children: [Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Latin · Fraunces"), Text("The quiet system"), Text("A serif display face carries the Latin headline — high contrast, optical sizing, an editorial register that reads as considered rather than default."), Text("Fraunces · opsz 9–144")]), Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("עברית · Frank Ruhl Libre"), Text("המערכת השקטה"), Text("פרנק-רוהל נושא את הכותרת העברית — נגזרת קלאסית, משקל אחד כבד, קול עורכי שקורא כמכוון ולא כברירת-מחדל."), Text("Frank Ruhl Libre · 700")])]));
  }
}
