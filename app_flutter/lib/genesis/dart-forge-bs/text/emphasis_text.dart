// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "text" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/text-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// EmphasisText — seam:fields · 9 חריצים
class ForgeEmphasisText extends StatelessWidget {
  /// תפר-דאטה (G12a): 9 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 9;
  static const List<String> fieldDemo = <String>["טקסט ראשי בדגש", " נושא את המשקל, ", "טקסט משני מוסר הקשר", ", ו", "טקסט עמום נושא מטא-דאטה", " בשוליים — שלוש דרגות מאותו טוקן.", "--ink", "--mut", "--faint"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  /// G13a · תוכן-נוסף בתוך מסגרת-האטום, אחרי זרימת-העיצוב (מקטע/כרטיס ⇒ תוכן-המודול). null ⇒ האטום לבדו.
  final Widget? child;
  // G13a · תוכן-נוסף בתוך המסגרת; null ⇒ ביט-זהה. גובה-חסום (Expanded/SizedBox סביב המסגרת) ⇒ התוכן ממלא (Expanded — רשימות/גלילה חיות, כמו GlassCard(child) של הזהב); גובה-חופשי ⇒ Column מכווץ-לתוכן.
  static Widget _withChild(Widget w, Widget? c) => c == null ? w : LayoutBuilder(builder: (ctx, cns) => cns.hasBoundedHeight
      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, Expanded(child: c)])
      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, c]));
  /// G13a · קבוצת-פריטים: items[i] = חריצי-הטקסט של פריט i (1 חריצים · 3 בדמו). null ⇒ פריטי-העיצוב.
  final List<List<String>>? items;
  static const int itemSlots = 1;
  static const int itemDemo = 3;
  String _it(List<String> r, int j, String d) => items == null ? d : (j < r.length ? r[j] : '');
  const ForgeEmphasisText({super.key, this.fields, this.child, this.items});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    final Widget body = Container(padding: const EdgeInsets.fromLTRB(24, 22, 24, 22), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: _withChild(Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [IntrinsicWidth(child: Text.rich(TextSpan(children: [TextSpan(text: _f(0, "טקסט ראשי בדגש"), style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 15, fontWeight: FontWeight.w600, height: 1.9, leadingDistribution: TextLeadingDistribution.even)), TextSpan(text: _f(1, " נושא את המשקל, "), style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 15, height: 1.9, leadingDistribution: TextLeadingDistribution.even)), TextSpan(text: _f(2, "טקסט משני מוסר הקשר"), style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 15, height: 1.9, leadingDistribution: TextLeadingDistribution.even)), TextSpan(text: _f(3, ", ו"), style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 15, height: 1.9, leadingDistribution: TextLeadingDistribution.even)), TextSpan(text: _f(4, "טקסט עמום נושא מטא-דאטה"), style: TextStyle(color: skin.faint, fontFamily: fonts.he, fontSize: 15, height: 1.9, leadingDistribution: TextLeadingDistribution.even)), TextSpan(text: _f(5, " בשוליים — שלוש דרגות מאותו טוקן."), style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 15, height: 1.9, leadingDistribution: TextLeadingDistribution.even))]))), const SizedBox(height: 16), Wrap(spacing: 10, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [...(items == null ? <Widget>[Directionality(textDirection: TextDirection.ltr, child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 8, children: [Container(width: 12, height: 12, decoration: BoxDecoration(color: skin.ink, borderRadius: BorderRadius.circular(4))), Text(_f(6, "--ink"), style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 10))])), Directionality(textDirection: TextDirection.ltr, child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 8, children: [Container(width: 12, height: 12, decoration: BoxDecoration(color: skin.mut, borderRadius: BorderRadius.circular(4))), Text(_f(7, "--mut"), style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 10))])), Directionality(textDirection: TextDirection.ltr, child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 8, children: [Container(width: 12, height: 12, decoration: BoxDecoration(color: skin.faint, borderRadius: BorderRadius.circular(4))), Text(_f(8, "--faint"), style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 10))]))] : List<Widget>.generate(items!.length, (i) => Directionality(textDirection: TextDirection.ltr, child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 8, children: [Container(width: 12, height: 12, decoration: BoxDecoration(color: skin.ink, borderRadius: BorderRadius.circular(4))), Text(_it(items![i], 0, "--ink"), style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 10))]))))])]), child));
    return body;
  }
}
