// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "text" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/text-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// TruncOne — seam:fields
class ForgeTruncOne extends StatelessWidget {
  const ForgeTruncOne({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(24, 22, 24, 22), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: IntrinsicWidth(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Directionality(textDirection: TextDirection.ltr, child: Text("SINGLE-LINE · ELLIPSIS", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 9, letterSpacing: 1))), const SizedBox(height: 6), Text("לורם איפסום דולור סיט אמט קונסקטורר אדיפיסינג אלית נתונים בזרם", style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 14))])));
  }
}
