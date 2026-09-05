// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "input" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/input-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// 4 atoms — seam:fields · 8 חריצים
class Forge4AtomsInput extends StatelessWidget {
  /// תפר-דאטה (G12a): 8 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 8;
  static const List<String> fieldDemo = <String>["−", "2", "+", "INHERIT NUMBERSTEPPER →", "QtyStepper", "StoreSmartQtyStepper", "NumberRow", "SettingsNumberRow"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  const Forge4AtomsInput({super.key, this.fields});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return SizedBox(width: double.infinity, child: Wrap(spacing: 14, runSpacing: 14, crossAxisAlignment: WrapCrossAlignment.center, children: [Container(decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [Container(width: 42, height: 44, alignment: Alignment.center, child: Text(_f(0, "−"), style: TextStyle(color: skin.ink, fontSize: 18, fontFamily: fonts.he))), Directionality(textDirection: TextDirection.ltr, child: Container(constraints: const BoxConstraints(minWidth: 46), child: Text(_f(1, "2"), textAlign: TextAlign.center, style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 16, fontWeight: FontWeight.w600)))), Container(width: 42, height: 44, alignment: Alignment.center, child: Text(_f(2, "+"), style: TextStyle(color: skin.ink, fontSize: 18, fontFamily: fonts.he)))])), Directionality(textDirection: TextDirection.ltr, child: Text(_f(3, "INHERIT NUMBERSTEPPER →"), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 9, letterSpacing: 1))), Wrap(spacing: 6, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(9, 4, 9, 4), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Text(_f(4, "QtyStepper"), style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 10)))), Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(9, 4, 9, 4), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Text(_f(5, "StoreSmartQtyStepper"), style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 10)))), Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(9, 4, 9, 4), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Text(_f(6, "NumberRow"), style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 10)))), Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(9, 4, 9, 4), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Text(_f(7, "SettingsNumberRow"), style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 10))))])]));
  }
}
