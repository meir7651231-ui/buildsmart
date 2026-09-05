// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "input" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/input-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// SmartQtyStepper — seam:fields · 6 חריצים
class ForgeSmartQtyStepper extends StatelessWidget {
  /// תפר-דאטה (G12a): 6 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 6;
  static const List<String> fieldDemo = <String>["−", "1", "+", "+5", "+10", "Max"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  const ForgeSmartQtyStepper({super.key, this.fields});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 8, children: [Container(decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [Container(width: 42, height: 44, alignment: Alignment.center, child: Text(_f(0, "−"), style: TextStyle(color: skin.ink, fontSize: 18, fontFamily: fonts.he))), Directionality(textDirection: TextDirection.ltr, child: Container(constraints: const BoxConstraints(minWidth: 46), child: Text(_f(1, "1"), textAlign: TextAlign.center, style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 16, fontWeight: FontWeight.w600)))), Container(width: 42, height: 44, alignment: Alignment.center, child: Text(_f(2, "+"), style: TextStyle(color: skin.ink, fontSize: 18, fontFamily: fonts.he)))])), Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 6, children: [Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(10, 4, 10, 4), decoration: BoxDecoration(color: theme.a.withValues(alpha: 0.120), border: Border.all(color: theme.a.withValues(alpha: 0.300)), borderRadius: BorderRadius.circular(999)), child: Text(_f(3, "+5"), style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11)))), Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(10, 4, 10, 4), decoration: BoxDecoration(color: theme.a.withValues(alpha: 0.120), border: Border.all(color: theme.a.withValues(alpha: 0.300)), borderRadius: BorderRadius.circular(999)), child: Text(_f(4, "+10"), style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11)))), Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(10, 4, 10, 4), decoration: BoxDecoration(color: theme.a.withValues(alpha: 0.120), border: Border.all(color: theme.a.withValues(alpha: 0.300)), borderRadius: BorderRadius.circular(999)), child: Text(_f(5, "Max"), style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11))))])]);
  }
}
