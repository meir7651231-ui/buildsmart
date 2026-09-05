// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "feedback" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/feedback-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// ConfirmDialog — seam:fields · 4 חריצים
class ForgeConfirmDialog extends StatelessWidget {
  /// תפר-דאטה (G12a): 4 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 4;
  static const List<String> fieldDemo = <String>["Label", "Meta", "Action", "Action"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  const ForgeConfirmDialog({super.key, this.fields});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(18, 18, 18, 18), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.raised, skin.surface], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0x99000000), offset: const Offset(0, 30), blurRadius: 80, spreadRadius: 0)]), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 12, children: [Text(_f(0, "Label"), style: TextStyle(color: skin.ink, fontFamily: fonts.serifHe, fontSize: 16, fontWeight: FontWeight.w700)), Text(_f(1, "Meta"), style: TextStyle(color: skin.mut, fontSize: 12.5, fontFamily: fonts.he)), Container(margin: const EdgeInsets.fromLTRB(0, 2, 0, 0), child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, spacing: 9, children: [Container(height: 44, padding: const EdgeInsets.fromLTRB(15, 0, 15, 0), decoration: BoxDecoration(gradient: LinearGradient(colors: [const Color(0xFFE8756C), skin.err], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(10)), child: Center(widthFactor: 1.0, child: Text(_f(2, "Action"), style: TextStyle(color: const Color(0xFFFFFFFF), fontFamily: fonts.he, fontSize: 12.5, fontWeight: FontWeight.w700)))), Container(height: 44, padding: const EdgeInsets.fromLTRB(15, 0, 15, 0), decoration: BoxDecoration(color: skin.raised2, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(10)), child: Center(widthFactor: 1.0, child: Text(_f(3, "Action"), style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 12.5, fontWeight: FontWeight.w700))))]))]));
  }
}
