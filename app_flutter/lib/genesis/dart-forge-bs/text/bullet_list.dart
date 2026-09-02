// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "text" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/text-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// BulletList — seam:fields
class ForgeBulletList extends StatelessWidget {
  const ForgeBulletList({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(24, 22, 24, 22), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Container(margin: const EdgeInsets.fromLTRB(0, 8, 0, 8), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 14, fontWeight: FontWeight.w600, height: 1.75)), Text("— לורם איפסום דולור סיט אמט קונסקטורר.", style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 14, height: 1.75))])), Container(margin: const EdgeInsets.fromLTRB(0, 8, 0, 8), child: Text("אדיפיסינג אלית, שורה שנייה ברוחב נוח.", style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 14, height: 1.75))), Container(margin: const EdgeInsets.fromLTRB(0, 8, 0, 8), child: Text("Meta · פריט שלישי קצר.", style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 14, height: 1.75)))]));
  }
}
