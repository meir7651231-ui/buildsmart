// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "card" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/card-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// PulsingStatus — seam:fields · 1 חריצים
class ForgePulsingStatus extends StatelessWidget {
  /// תפר-דאטה (G12a): 1 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 1;
  static const List<String> fieldDemo = <String>["Label · Meta"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  const ForgePulsingStatus({super.key, this.fields});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(2, 10, 2, 10), child: Wrap(spacing: 14, runSpacing: 14, crossAxisAlignment: WrapCrossAlignment.center, children: [Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 8, children: [Container(width: 9, height: 9, decoration: BoxDecoration(color: skin.ok, borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: skin.ok, offset: const Offset(0, 0), blurRadius: 0, spreadRadius: 3)])), Text(_f(0, "Label · Meta"), style: TextStyle(color: skin.mut, fontSize: 12, fontFamily: fonts.he))])]));
  }
}
