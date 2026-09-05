// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "selection" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/selection-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// RatingBars — seam:value · 3 חריצים
class ForgeRatingBarsSelection extends StatelessWidget {
  /// תפר-דאטה (G12a): 3 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 3;
  static const List<String> fieldDemo = <String>["Value ", "3", " / 5"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  /// G13a · תוכן-נוסף בתוך מסגרת-האטום, אחרי זרימת-העיצוב (מקטע/כרטיס ⇒ תוכן-המודול). null ⇒ האטום לבדו.
  final Widget? child;
  // G13a · תוכן-נוסף בתוך המסגרת; null ⇒ ביט-זהה. גובה-חסום (Expanded/SizedBox סביב המסגרת) ⇒ התוכן ממלא (Expanded — רשימות/גלילה חיות, כמו GlassCard(child) של הזהב); גובה-חופשי ⇒ Column מכווץ-לתוכן.
  static Widget _withChild(Widget w, Widget? c) => c == null ? w : LayoutBuilder(builder: (ctx, cns) => cns.hasBoundedHeight
      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, Expanded(child: c)])
      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, c]));
  /// G13b · bare=true ⇒ ליבת-הבקרה בלי מסגרת-הגלריה של Pure (.ctl/.body/.stage); child נכנס לליבה. false ⇒ ביט-זהה לגלריה.
  final bool bare;
  /// G13a · קבוצת-פריטים: items[i] = חריצי-הטקסט של פריט i (0 חריצים · 5 בדמו · selected = הפריטים-הפעילים). null ⇒ פריטי-העיצוב.
  final List<List<String>>? items;
  final Set<int>? selected;
  static const int itemSlots = 0;
  static const int itemDemo = 5;
  String _it(List<String> r, int j, String d) => items == null ? d : (j < r.length ? r[j] : '');
  /// G13a · מילויי-אחוז (0..1) לפי סדר-הופעה/פריט (4 בדמו). null ⇒ ערכי-העיצוב; חסר ⇒ 0 (אין המצאה).
  final List<double>? values;
  double _v(int i, double d) => values == null ? d : (i < values!.length ? values![i].clamp(0.0, 1.0) : 0.0);
  const ForgeRatingBarsSelection({super.key, this.fields, this.child, this.bare = false, this.items, this.selected, this.values});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    final Widget core = Container(margin: const EdgeInsets.fromLTRB(0, 0, 0, 0), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Container(height: 34, child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.end, spacing: 5, children: [...(items == null ? <Widget>[FractionallySizedBox(heightFactor: _v(0, 0.400), alignment: Alignment.centerRight, child: Container(width: 16, decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(3)))), FractionallySizedBox(heightFactor: _v(1, 0.580), alignment: Alignment.centerRight, child: Container(width: 16, decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(3)))), FractionallySizedBox(heightFactor: _v(2, 0.720), alignment: Alignment.centerRight, child: Container(width: 16, decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(3)))), FractionallySizedBox(heightFactor: _v(3, 0.860), alignment: Alignment.centerRight, child: Container(width: 16, decoration: BoxDecoration(color: skin.raised2, borderRadius: BorderRadius.circular(3)))), Container(width: 16, decoration: BoxDecoration(color: skin.raised2, borderRadius: BorderRadius.circular(3)))] : List<Widget>.generate(items!.length, (i) => Flexible(child: ((selected?.contains(i) ?? false) ? FractionallySizedBox(heightFactor: _v(i, 0.400), alignment: Alignment.centerRight, child: Container(width: 16, decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(3)))) : FractionallySizedBox(heightFactor: _v(i, 0.860), alignment: Alignment.centerRight, child: Container(width: 16, decoration: BoxDecoration(color: skin.raised2, borderRadius: BorderRadius.circular(3))))))))])), const SizedBox(height: 10), Directionality(textDirection: TextDirection.ltr, child: Text.rich(TextSpan(children: [TextSpan(text: _f(0, "Value "), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 10)), TextSpan(text: _f(1, "3"), style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 10)), TextSpan(text: _f(2, " / 5"), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 10))])))]));
    final Widget body = bare ? _withChild(core, child) : Container(height: 130, padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(15)), child: _withChild(Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, spacing: 11, children: [core]), child));
    return body;
  }
}
