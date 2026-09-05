// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "status" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/status-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// ScoreBandChip — seam:fields · 5 חריצים
class ForgeScoreBandChip extends StatelessWidget {
  /// תפר-דאטה (G12a): 5 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 5;
  static const List<String> fieldDemo = <String>["76", "0", "40", "70", "100"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  /// G13a · תוכן-נוסף בתוך מסגרת-האטום, אחרי זרימת-העיצוב (מקטע/כרטיס ⇒ תוכן-המודול). null ⇒ האטום לבדו.
  final Widget? child;
  // G13a · תוכן-נוסף בתוך המסגרת; null ⇒ ביט-זהה. גובה-חסום (Expanded/SizedBox סביב המסגרת) ⇒ התוכן ממלא (Expanded — רשימות/גלילה חיות, כמו GlassCard(child) של הזהב); גובה-חופשי ⇒ Column מכווץ-לתוכן.
  static Widget _withChild(Widget w, Widget? c) => c == null ? w : LayoutBuilder(builder: (ctx, cns) => cns.hasBoundedHeight
      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, Expanded(child: c)])
      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, c]));
  /// G13a · קבוצת-פריטים: items[i] = חריצי-הטקסט של פריט i (1 חריצים · 4 בדמו). null ⇒ פריטי-העיצוב.
  final List<List<String>>? items;
  static const int itemSlots = 1;
  static const int itemDemo = 4;
  String _it(List<String> r, int j, String d) => items == null ? d : (j < r.length ? r[j] : '');
  /// G13a · מילויי-אחוז (0..1) לפי סדר-הופעה/פריט (3 בדמו). null ⇒ ערכי-העיצוב; חסר ⇒ 0 (אין המצאה).
  final List<double>? values;
  double _v(int i, double d) => values == null ? d : (i < values!.length ? values![i].clamp(0.0, 1.0) : 0.0);
  const ForgeScoreBandChip({super.key, this.fields, this.child, this.items, this.values});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    final Widget body = Container(padding: const EdgeInsets.fromLTRB(4, 14, 4, 4), child: _withChild(Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 10, children: [Container(height: 20, child: Stack(clipBehavior: Clip.none, children: [Positioned(top: -16, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [Directionality(textDirection: TextDirection.ltr, child: Text(_f(0, "76"), style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11, fontWeight: FontWeight.w700))), Container(margin: const EdgeInsets.fromLTRB(0, 2, 0, 0), decoration: BoxDecoration(border: Border(top: BorderSide(color: skin.ink, width: 7))))]))])), Container(height: 9, decoration: BoxDecoration(borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, children: [Expanded(flex: 40, child: FractionallySizedBox(widthFactor: _v(0, 0.400), alignment: Alignment.centerRight, child: Container(decoration: BoxDecoration(color: skin.err.withValues(alpha: 0.780))))), Expanded(flex: 30, child: FractionallySizedBox(widthFactor: _v(1, 0.300), alignment: Alignment.centerRight, child: Container(decoration: BoxDecoration(color: skin.warn.withValues(alpha: 0.780))))), Expanded(flex: 30, child: FractionallySizedBox(widthFactor: _v(2, 0.300), alignment: Alignment.centerRight, child: Container(decoration: BoxDecoration(color: skin.ok.withValues(alpha: 0.820)))))])), SizedBox(width: double.infinity, child: Directionality(textDirection: TextDirection.ltr, child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [...(items == null ? <Widget>[Flexible(child: Text(_f(1, "0"), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 8.5), overflow: TextOverflow.ellipsis, softWrap: false)), Flexible(child: Text(_f(2, "40"), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 8.5), overflow: TextOverflow.ellipsis, softWrap: false)), Flexible(child: Text(_f(3, "70"), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 8.5), overflow: TextOverflow.ellipsis, softWrap: false)), Flexible(child: Text(_f(4, "100"), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 8.5), overflow: TextOverflow.ellipsis, softWrap: false))] : List<Widget>.generate(items!.length, (i) => Flexible(child: Text(_it(items![i], 0, "0"), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 8.5)))))])))]), child));
    return body;
  }
}
