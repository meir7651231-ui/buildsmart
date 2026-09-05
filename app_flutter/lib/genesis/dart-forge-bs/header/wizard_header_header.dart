// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "header" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/header-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// WizardHeader — seam:progress · 5 חריצים
class ForgeWizardHeaderHeader extends StatelessWidget {
  /// תפר-דאטה (G12a): 5 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 5;
  static const List<String> fieldDemo = <String>["Step ", "2", " of 5", "Label", "Meta"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  /// G13a · תוכן-נוסף בתוך מסגרת-האטום, אחרי זרימת-העיצוב (מקטע/כרטיס ⇒ תוכן-המודול). null ⇒ האטום לבדו.
  final Widget? child;
  // G13a · תוכן-נוסף בתוך המסגרת; null ⇒ ביט-זהה. גובה-חסום (Expanded/SizedBox סביב המסגרת) ⇒ התוכן ממלא (Expanded — רשימות/גלילה חיות, כמו GlassCard(child) של הזהב); גובה-חופשי ⇒ Column מכווץ-לתוכן.
  static Widget _withChild(Widget w, Widget? c) => c == null ? w : LayoutBuilder(builder: (ctx, cns) => cns.hasBoundedHeight
      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, Expanded(child: c)])
      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, c]));
  static Widget _hide(String s, Widget w) => s.isEmpty ? const SizedBox.shrink() : w;   // G13a · חריץ-ריק ⇒ הקופסה נעלמת
  /// G13a · קבוצת-פריטים: items[i] = חריצי-הטקסט של פריט i (0 חריצים · 3 בדמו). null ⇒ פריטי-העיצוב.
  final List<List<String>>? items;
  static const int itemSlots = 0;
  static const int itemDemo = 3;
  String _it(List<String> r, int j, String d) => items == null ? d : (j < r.length ? r[j] : '');
  /// G13a · מילויי-אחוז (0..1) לפי סדר-הופעה/פריט (1 בדמו). null ⇒ ערכי-העיצוב; חסר ⇒ 0 (אין המצאה).
  final List<double>? values;
  double _v(int i, double d) => values == null ? d : (i < values!.length ? values![i].clamp(0.0, 1.0) : 0.0);
  const ForgeWizardHeaderHeader({super.key, this.fields, this.child, this.items, this.values});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    final Widget body = Container(padding: const EdgeInsets.fromLTRB(22, 20, 22, 20), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: _withChild(Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, spacing: 12, children: [Directionality(textDirection: TextDirection.ltr, child: Text.rich(TextSpan(children: [TextSpan(text: _f(0, "Step "), style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11, fontWeight: FontWeight.w600)), TextSpan(text: _f(1, "2"), style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11, fontWeight: FontWeight.w700)), TextSpan(text: _f(2, " of 5"), style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11, fontWeight: FontWeight.w600))]))), Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 7, children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: theme.a, borderRadius: BorderRadius.circular(999))), Container(width: 8, height: 8, decoration: BoxDecoration(color: theme.aHi, borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: theme.a, offset: const Offset(0, 0), blurRadius: 0, spreadRadius: 3)])), ...(items == null ? <Widget>[Container(width: 8, height: 8, decoration: BoxDecoration(color: skin.hair, borderRadius: BorderRadius.circular(999))), Container(width: 8, height: 8, decoration: BoxDecoration(color: skin.hair, borderRadius: BorderRadius.circular(999))), Container(width: 8, height: 8, decoration: BoxDecoration(color: skin.hair, borderRadius: BorderRadius.circular(999)))] : List<Widget>.generate(items!.length, (i) => Flexible(child: Container(width: 8, height: 8, decoration: BoxDecoration(color: skin.hair, borderRadius: BorderRadius.circular(999))))))])]), const SizedBox(height: 12), SizedBox(width: double.infinity, child: Container(height: 6, decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair2), borderRadius: BorderRadius.circular(999)), child: FractionallySizedBox(widthFactor: _v(0, 0.400), alignment: Alignment.centerRight, child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.a, theme.aHi], begin: Alignment.centerLeft, end: Alignment.centerRight), borderRadius: BorderRadius.circular(999)))))), const SizedBox(height: 14), Text(_f(3, "Label"), style: TextStyle(color: skin.ink, fontFamily: fonts.serifHe, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.20, height: 1.05, leadingDistribution: TextLeadingDistribution.even)), const SizedBox(height: 7), _hide(_f(4, "Meta"), IntrinsicWidth(child: Text(_f(4, "Meta"), style: TextStyle(color: skin.mut, fontSize: 12.5, height: 1.45, leadingDistribution: TextLeadingDistribution.even, fontFamily: fonts.he))))]), child));
    return body;
  }
}
