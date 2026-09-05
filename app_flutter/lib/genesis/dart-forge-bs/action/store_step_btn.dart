// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "action" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/action-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// StoreStepBtn — seam:fields · 4 חריצים
class ForgeStoreStepBtn extends StatelessWidget {
  /// תפר-דאטה (G12a): 4 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 4;
  static const List<String> fieldDemo = <String>["QTY", "−", "1", "+"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  const ForgeStoreStepBtn({super.key, this.fields});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Text.rich(TextSpan(children: [TextSpan(text: _f(0, "QTY"), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 9, letterSpacing: 1)), WidgetSpan(alignment: PlaceholderAlignment.middle, child: Container(decoration: BoxDecoration(color: skin.raised, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [Container(width: 38, height: 44, alignment: Alignment.center, child: Text(_f(1, "−"), style: TextStyle(color: skin.ink, fontSize: 17, fontFamily: fonts.he))), Container(constraints: const BoxConstraints(minWidth: 40), child: Text(_f(2, "1"), textAlign: TextAlign.center, style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 16, fontWeight: FontWeight.w600))), Container(width: 38, height: 44, alignment: Alignment.center, child: Text(_f(3, "+"), style: TextStyle(color: skin.ink, fontSize: 17, fontFamily: fonts.he)))])))]));
  }
}
