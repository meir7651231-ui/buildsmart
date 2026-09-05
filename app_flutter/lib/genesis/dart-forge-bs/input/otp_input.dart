// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "input" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/input-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// OtpInput — seam:fields · 2 חריצים
class ForgeOtpInput extends StatelessWidget {
  /// תפר-דאטה (G12a): 2 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 2;
  static const List<String> fieldDemo = <String>["2", "6"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  const ForgeOtpInput({super.key, this.fields});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Directionality(textDirection: TextDirection.ltr, child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 9, children: [Container(width: 44, height: 52, alignment: Alignment.center, decoration: BoxDecoration(color: skin.surface, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11), boxShadow: [BoxShadow(color: theme.gl, offset: const Offset(0, 0), blurRadius: 0, spreadRadius: 3)]), child: Text(_f(0, "2"), style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 20, fontWeight: FontWeight.w600))), Container(width: 44, height: 52, alignment: Alignment.center, decoration: BoxDecoration(color: skin.surface, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11), boxShadow: [BoxShadow(color: theme.gl, offset: const Offset(0, 0), blurRadius: 0, spreadRadius: 3)]), child: Text(_f(1, "6"), style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 20, fontWeight: FontWeight.w600))), Container(width: 44, height: 52, alignment: Alignment.center, decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11), boxShadow: [BoxShadow(color: theme.gl, offset: const Offset(0, 0), blurRadius: 0, spreadRadius: 3)]), child: Container(width: 2, height: 22, decoration: BoxDecoration(color: theme.aHi))), Container(width: 44, height: 52, alignment: Alignment.center, decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)))]));
  }
}
