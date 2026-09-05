// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "dataviz" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/dataviz-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// ChartLegend — seam:series · 7 חריצים
class ForgeChartLegend extends StatelessWidget {
  /// תפר-דאטה (G12a): 7 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 7;
  static const List<String> fieldDemo = <String>["Label", "Label", "164", "Label", "86", "Label", "73"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  /// G13a · תוכן-נוסף בתוך מסגרת-האטום, אחרי זרימת-העיצוב (מקטע/כרטיס ⇒ תוכן-המודול). null ⇒ האטום לבדו.
  final Widget? child;
  // G13a · תוכן-נוסף בתוך המסגרת; null ⇒ ביט-זהה. גובה-חסום (Expanded/SizedBox סביב המסגרת) ⇒ התוכן ממלא (Expanded — רשימות/גלילה חיות, כמו GlassCard(child) של הזהב); גובה-חופשי ⇒ Column מכווץ-לתוכן.
  static Widget _withChild(Widget w, Widget? c) => c == null ? w : LayoutBuilder(builder: (ctx, cns) => cns.hasBoundedHeight
      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, Expanded(child: c)])
      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, c]));
  /// G13a · קבוצת-פריטים: items[i] = חריצי-הטקסט של פריט i (2 חריצים · 3 בדמו). null ⇒ פריטי-העיצוב.
  final List<List<String>>? items;
  static const int itemSlots = 2;
  static const int itemDemo = 3;
  String _it(List<String> r, int j, String d) => items == null ? d : (j < r.length ? r[j] : '');
  const ForgeChartLegend({super.key, this.fields, this.child, this.items});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    final Widget body = Container(padding: const EdgeInsets.fromLTRB(16, 16, 16, 13), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: _withChild(Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 11, children: [Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, spacing: 10, children: [Flexible(child: Text(_f(0, "Label"), style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis, softWrap: false))]), Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 10, children: [...(items == null ? <Widget>[Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 7, children: [Container(width: 11, height: 11, decoration: BoxDecoration(color: theme.a, borderRadius: BorderRadius.circular(3))), Text(_f(1, "Label"), style: TextStyle(color: skin.mut, fontSize: 11.5, fontFamily: fonts.he)), Flexible(child: Directionality(textDirection: TextDirection.ltr, child: Text(_f(2, "164"), style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11.5, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis, softWrap: false)))]), Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 7, children: [Container(width: 11, height: 11, decoration: BoxDecoration(color: theme.c2, borderRadius: BorderRadius.circular(3))), Text(_f(3, "Label"), style: TextStyle(color: skin.mut, fontSize: 11.5, fontFamily: fonts.he)), Flexible(child: Directionality(textDirection: TextDirection.ltr, child: Text(_f(4, "86"), style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11.5, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis, softWrap: false)))]), Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 7, children: [Container(width: 11, height: 11, decoration: BoxDecoration(color: theme.c3, borderRadius: BorderRadius.circular(3))), Text(_f(5, "Label"), style: TextStyle(color: skin.mut, fontSize: 11.5, fontFamily: fonts.he)), Flexible(child: Directionality(textDirection: TextDirection.ltr, child: Text(_f(6, "73"), style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11.5, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis, softWrap: false)))])] : List<Widget>.generate(items!.length, (i) => Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 7, children: [Container(width: 11, height: 11, decoration: BoxDecoration(color: theme.a, borderRadius: BorderRadius.circular(3))), Text(_it(items![i], 0, "Label"), style: TextStyle(color: skin.mut, fontSize: 11.5, fontFamily: fonts.he)), Flexible(child: Directionality(textDirection: TextDirection.ltr, child: Text(_it(items![i], 1, "164"), style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11.5, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis, softWrap: false)))])))])]), child));
    return body;
  }
}
