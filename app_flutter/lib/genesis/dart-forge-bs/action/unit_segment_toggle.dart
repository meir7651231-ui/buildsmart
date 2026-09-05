// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "action" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/action-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// UnitSegmentToggle — seam:fields · 2 חריצים
class ForgeUnitSegmentToggle extends StatelessWidget {
  /// תפר-דאטה (G12a): 2 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 2;
  static const List<String> fieldDemo = <String>["Label", "Label"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  const ForgeUnitSegmentToggle({super.key, this.fields});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return SizedBox(width: double.infinity, child: Container(decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(10)), child: Stack(clipBehavior: Clip.none, children: [Positioned(top: 3, bottom: 3, left: 0, child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.raised2, skin.raised], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(7), boxShadow: [BoxShadow(color: const Color(0x66000000), offset: const Offset(0, 2), blurRadius: 6, spreadRadius: 0)]))), Padding(padding: const EdgeInsets.fromLTRB(3, 3, 3, 3), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [Expanded(child: Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(8, 8, 8, 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(7)), child: Center(widthFactor: 1.0, heightFactor: 1.0, child: Text(_f(0, "Label"), style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 12, fontWeight: FontWeight.w600))))), Expanded(child: Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(8, 8, 8, 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(7)), child: Center(widthFactor: 1.0, heightFactor: 1.0, child: Text(_f(1, "Label"), style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 12, fontWeight: FontWeight.w600)))))]))])));
  }
}
