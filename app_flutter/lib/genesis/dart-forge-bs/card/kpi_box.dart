// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "card" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/card-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// KpiBox — seam:series · 2 חריצים
class ForgeKpiBox extends StatelessWidget {
  /// תפר-דאטה (G12a): 2 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 2;
  static const List<String> fieldDemo = <String>["Label", "92"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  /// G13a · תוכן-נוסף בתוך מסגרת-האטום, אחרי זרימת-העיצוב (מקטע/כרטיס ⇒ תוכן-המודול). null ⇒ האטום לבדו.
  final Widget? child;
  // G13a · תוכן-נוסף בתוך המסגרת; null ⇒ ביט-זהה. גובה-חסום (Expanded/SizedBox סביב המסגרת) ⇒ התוכן ממלא (Expanded — רשימות/גלילה חיות, כמו GlassCard(child) של הזהב); גובה-חופשי ⇒ Column מכווץ-לתוכן.
  static Widget _withChild(Widget w, Widget? c) => c == null ? w : LayoutBuilder(builder: (ctx, cns) => cns.hasBoundedHeight
      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, Expanded(child: c)])
      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, c]));
  /// G13a · קבוצת-פריטים: items[i] = חריצי-הטקסט של פריט i (0 חריצים · 7 בדמו). null ⇒ פריטי-העיצוב.
  final List<List<String>>? items;
  static const int itemSlots = 0;
  static const int itemDemo = 7;
  String _it(List<String> r, int j, String d) => items == null ? d : (j < r.length ? r[j] : '');
  /// G13a · מילויי-אחוז (0..1) לפי סדר-הופעה/פריט (6 בדמו). null ⇒ ערכי-העיצוב; חסר ⇒ 0 (אין המצאה).
  final List<double>? values;
  double _v(int i, double d) => values == null ? d : (i < values!.length ? values![i].clamp(0.0, 1.0) : 0.0);
  const ForgeKpiBox({super.key, this.fields, this.child, this.items, this.values});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    final Widget body = Container(padding: const EdgeInsets.fromLTRB(16, 15, 16, 15), decoration: BoxDecoration(gradient: RadialGradient(center: Alignment(0.70, -1.40), radius: 1.20, colors: [theme.gl, skin.surface], stops: [0.0, 0.55]), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(14)), child: _withChild(Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 6, children: [Text(_f(0, "Label"), style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 11, fontWeight: FontWeight.w600)), SizedBox(width: double.infinity, child: Directionality(textDirection: TextDirection.ltr, child: Text(_f(1, "92"), style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 30, fontWeight: FontWeight.w700, letterSpacing: -0.60, height: 1, leadingDistribution: TextLeadingDistribution.even)))), Container(height: 26, margin: const EdgeInsets.fromLTRB(0, 2, 0, 0), child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.end, spacing: 3, children: [...(items == null ? <Widget>[Expanded(child: FractionallySizedBox(heightFactor: _v(0, 0.400), alignment: Alignment.centerRight, child: Opacity(opacity: 0.85, child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(2)))))), Expanded(child: FractionallySizedBox(heightFactor: _v(1, 0.550), alignment: Alignment.centerRight, child: Opacity(opacity: 0.85, child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(2)))))), Expanded(child: FractionallySizedBox(heightFactor: _v(2, 0.450), alignment: Alignment.centerRight, child: Opacity(opacity: 0.85, child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(2)))))), Expanded(child: FractionallySizedBox(heightFactor: _v(3, 0.700), alignment: Alignment.centerRight, child: Opacity(opacity: 0.85, child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(2)))))), Expanded(child: FractionallySizedBox(heightFactor: _v(4, 0.600), alignment: Alignment.centerRight, child: Opacity(opacity: 0.85, child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(2)))))), Expanded(child: FractionallySizedBox(heightFactor: _v(5, 0.850), alignment: Alignment.centerRight, child: Opacity(opacity: 0.85, child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(2)))))), Expanded(child: Opacity(opacity: 0.85, child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(2)))))] : List<Widget>.generate(items!.length, (i) => Expanded(child: FractionallySizedBox(heightFactor: _v(i, 0.400), alignment: Alignment.centerRight, child: Opacity(opacity: 0.85, child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(2))))))))]))]), child));
    return body;
  }
}
