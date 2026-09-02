// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "text" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/text-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// NumberedList — seam:fields
class ForgeNumberedList extends StatelessWidget {
  const ForgeNumberedList({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(24, 22, 24, 22), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Container(margin: const EdgeInsets.fromLTRB(0, 9, 0, 9), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Label", style: TextStyle(color: skin.ink, fontWeight: FontWeight.w600, fontFamily: fonts.he)), Text("— שלב ראשון בתהליך.", style: TextStyle(color: skin.mut, fontFamily: fonts.he))])), Container(margin: const EdgeInsets.fromLTRB(0, 9, 0, 9), child: Text("שלב שני, טקסט ממשיך בשורה נוחה.", style: TextStyle(color: skin.mut, fontFamily: fonts.he))), Container(margin: const EdgeInsets.fromLTRB(0, 9, 0, 9), child: Text("Meta · שלב שלישי.", style: TextStyle(color: skin.mut, fontFamily: fonts.he)))]));
  }
}
