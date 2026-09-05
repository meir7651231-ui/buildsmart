// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "action" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/action-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// MiniQtyBtn — seam:fields · 3 חריצים
class ForgeMiniQtyBtn extends StatelessWidget {
  /// תפר-דאטה (G12a): 3 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 3;
  static const List<String> fieldDemo = <String>["−", "3", "+"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  const ForgeMiniQtyBtn({super.key, this.fields});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(decoration: BoxDecoration(color: skin.raised, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [Container(width: 38, height: 44, alignment: Alignment.center, child: Text(_f(0, "−"), style: TextStyle(color: skin.ink, fontSize: 17, fontFamily: fonts.he))), Container(constraints: const BoxConstraints(minWidth: 40), child: Text(_f(1, "3"), textAlign: TextAlign.center, style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 12, fontWeight: FontWeight.w600))), Container(width: 38, height: 44, alignment: Alignment.center, child: Text(_f(2, "+"), style: TextStyle(color: skin.ink, fontSize: 17, fontFamily: fonts.he)))]));
  }
}
