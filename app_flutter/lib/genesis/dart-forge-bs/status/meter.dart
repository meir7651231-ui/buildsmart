// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "status" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/status-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// Meter — seam:fields · 2 חריצים
class ForgeMeter extends StatelessWidget {
  /// תפר-דאטה (G12a): 2 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 2;
  static const List<String> fieldDemo = <String>["Label", "94%"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  const ForgeMeter({super.key, this.fields});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(0, 6, 0, 6), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 7, children: [Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [Flexible(child: Text(_f(0, "Label"), style: TextStyle(color: skin.mut, fontSize: 11, fontWeight: FontWeight.w600, fontFamily: fonts.he), overflow: TextOverflow.ellipsis, softWrap: false)), Flexible(child: Directionality(textDirection: TextDirection.ltr, child: Text(_f(1, "94%"), style: TextStyle(color: skin.ok, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 12, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis, softWrap: false)))]), SizedBox(width: double.infinity, child: Container(height: 8, decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair2), borderRadius: BorderRadius.circular(999)), child: FractionallySizedBox(widthFactor: 0.940, alignment: Alignment.centerRight, child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.ok, Color.lerp(const Color(0xFFFFFFFF), skin.ok, 0.550)!], begin: Alignment.centerLeft, end: Alignment.centerRight), borderRadius: BorderRadius.circular(999))))))]));
  }
}
