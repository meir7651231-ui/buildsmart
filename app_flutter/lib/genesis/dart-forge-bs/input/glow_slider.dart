// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "input" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/input-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// GlowSlider — seam:fields · 1 חריצים
class ForgeGlowSlider extends StatelessWidget {
  /// תפר-דאטה (G12a): 1 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 1;
  static const List<String> fieldDemo = <String>["58"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  const ForgeGlowSlider({super.key, this.fields});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(4, 14, 4, 6), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Container(constraints: const BoxConstraints(minHeight: 44), child: Align(alignment: Alignment.centerRight, child: Text("58", style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 13)))), const SizedBox(height: 12), Directionality(textDirection: TextDirection.ltr, child: Text(_f(0, "58"), textAlign: TextAlign.center, style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11)))]));
  }
}
