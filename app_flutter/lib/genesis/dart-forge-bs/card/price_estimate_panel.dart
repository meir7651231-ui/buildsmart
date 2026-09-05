// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "card" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/card-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// PriceEstimatePanel — seam:fields · 6 חריצים
class ForgePriceEstimatePanel extends StatelessWidget {
  /// תפר-דאטה (G12a): 6 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 6;
  static const List<String> fieldDemo = <String>["Label", "248", "Label", "92", "Label", "340"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  const ForgePriceEstimatePanel({super.key, this.fields});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(14, 14, 14, 14), decoration: BoxDecoration(color: skin.surface, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(14)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.fromLTRB(0, 5, 0, 5), child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [Flexible(child: Text(_f(0, "Label"), style: TextStyle(color: skin.ink, fontSize: 12, fontFamily: fonts.he), overflow: TextOverflow.ellipsis, softWrap: false)), Flexible(child: Directionality(textDirection: TextDirection.ltr, child: Text(_f(1, "248"), style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 12), overflow: TextOverflow.ellipsis, softWrap: false)))])), Container(padding: const EdgeInsets.fromLTRB(0, 5, 0, 5), child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [Flexible(child: Text(_f(2, "Label"), style: TextStyle(color: skin.ink, fontSize: 12, fontFamily: fonts.he), overflow: TextOverflow.ellipsis, softWrap: false)), Flexible(child: Directionality(textDirection: TextDirection.ltr, child: Text(_f(3, "92"), style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 12), overflow: TextOverflow.ellipsis, softWrap: false)))])), const SizedBox(height: 6), Container(padding: const EdgeInsets.fromLTRB(0, 9, 0, 5), decoration: BoxDecoration(border: Border(top: BorderSide(color: skin.hair, width: 1))), child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [Flexible(child: Text(_f(4, "Label"), style: TextStyle(color: skin.ink, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: fonts.he), overflow: TextOverflow.ellipsis, softWrap: false)), Flexible(child: Directionality(textDirection: TextDirection.ltr, child: Text(_f(5, "340"), style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 12, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis, softWrap: false)))]))]));
  }
}
