// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "text" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/text-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// TypeScale — seam:series
class ForgeTypeScale extends StatelessWidget {
  const ForgeTypeScale({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 24), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 2, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Display"), Text("64 / 700", style: TextStyle(color: skin.ink, fontFamily: fonts.he))]), Text("כותרת ראשית", style: TextStyle(fontSize: 38))]), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("H1"), Text("44 / 700", style: TextStyle(color: skin.ink, fontFamily: fonts.he))]), Text("כותרת עמוד", style: TextStyle(fontSize: 30))]), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("H2"), Text("32 / 700", style: TextStyle(color: skin.ink, fontFamily: fonts.he))]), Text("כותרת מקטע", style: TextStyle(fontSize: 24))]), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("H3"), Text("22 / 700", style: TextStyle(color: skin.ink, fontFamily: fonts.he))]), Text("תת כותרת", style: TextStyle(fontSize: 22))]), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Body"), Text("15 / 400", style: TextStyle(color: skin.ink, fontFamily: fonts.he))]), Text("לורם איפסום דולור סיט אמט, קונסקטורר אדיפיסינג אלית. נתונים נטענים בזרם, השורות נשמרות ברוחב נוח לקריאה.", style: TextStyle(fontSize: 15))]), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Caption"), Text("12 / 400", style: TextStyle(color: skin.ink, fontFamily: fonts.he))]), Text("Meta · טקסט משני קטן", style: TextStyle(fontSize: 12))])]));
  }
}
