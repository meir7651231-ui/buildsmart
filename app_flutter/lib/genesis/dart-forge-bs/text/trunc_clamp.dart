// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "text" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/text-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// TruncClamp — seam:fields
class ForgeTruncClamp extends StatelessWidget {
  const ForgeTruncClamp({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(24, 22, 24, 22), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Container(margin: const EdgeInsets.fromLTRB(0, 0, 0, 6), child: Text("2-LINE · CLAMP", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 9))), Text("לורם איפסום דולור סיט אמט, קונסקטורר אדיפיסינג אלית. נתונים נטענים בזרם והשורה נחתכת בגבול השני בדיוק כאן.", style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 14))]));
  }
}
