// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "dataviz" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/dataviz-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// LegendRow — seam:fields · 5 חריצים
class ForgeLegendRow extends StatelessWidget {
  /// תפר-דאטה (G12a): 5 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 5;
  static const List<String> fieldDemo = <String>["Label", "Label", "Label", "Label", "Label"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  const ForgeLegendRow({super.key, this.fields});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(16, 16, 16, 13), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 11, children: [Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, spacing: 10, children: [Flexible(child: Text(_f(0, "Label"), style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis, softWrap: false))]), Wrap(spacing: 12, runSpacing: 12, crossAxisAlignment: WrapCrossAlignment.center, children: [Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 7, children: [Container(width: 11, height: 11, decoration: BoxDecoration(color: theme.a, borderRadius: BorderRadius.circular(3))), Text(_f(1, "Label"), style: TextStyle(color: skin.mut, fontSize: 11.5, fontFamily: fonts.he))]), Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 7, children: [Container(width: 11, height: 11, decoration: BoxDecoration(color: theme.c2, borderRadius: BorderRadius.circular(3))), Text(_f(2, "Label"), style: TextStyle(color: skin.mut, fontSize: 11.5, fontFamily: fonts.he))]), Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 7, children: [Container(width: 11, height: 11, decoration: BoxDecoration(color: theme.c3, borderRadius: BorderRadius.circular(3))), Text(_f(3, "Label"), style: TextStyle(color: skin.mut, fontSize: 11.5, fontFamily: fonts.he))]), Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 7, children: [Container(width: 11, height: 11, decoration: BoxDecoration(color: skin.faint, borderRadius: BorderRadius.circular(3))), Text(_f(4, "Label"), style: TextStyle(color: skin.mut, fontSize: 11.5, fontFamily: fonts.he))])])]));
  }
}
