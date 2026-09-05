// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "input" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/input-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// QtyStepperBox — seam:fields · 3 חריצים
class ForgeQtyStepperBox extends StatelessWidget {
  /// תפר-דאטה (G12a): 3 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 3;
  static const List<String> fieldDemo = <String>["+", "4", "−"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  const ForgeQtyStepperBox({super.key, this.fields});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(11)), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 8, children: [Container(width: 42, height: 44, alignment: Alignment.center, decoration: BoxDecoration(color: skin.raised, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(10)), child: Text(_f(0, "+"), style: TextStyle(color: skin.ink, fontSize: 18, fontFamily: fonts.he))), Directionality(textDirection: TextDirection.ltr, child: Container(height: 44, constraints: const BoxConstraints(minWidth: 46), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(10)), child: Center(widthFactor: 1.0, child: Text(_f(1, "4"), textAlign: TextAlign.center, style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 16, fontWeight: FontWeight.w600))))), Container(width: 42, height: 44, alignment: Alignment.center, decoration: BoxDecoration(color: skin.raised, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(10)), child: Text(_f(2, "−"), style: TextStyle(color: skin.ink, fontSize: 18, fontFamily: fonts.he)))]));
  }
}
