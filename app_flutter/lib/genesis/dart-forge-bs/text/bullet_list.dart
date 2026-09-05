// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "text" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/text-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// BulletList — seam:fields · 4 חריצים
class ForgeBulletList extends StatelessWidget {
  /// תפר-דאטה (G12a): 4 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 4;
  static const List<String> fieldDemo = <String>["Label", " — לורם איפסום דולור סיט אמט קונסקטורר.", "אדיפיסינג אלית, שורה שנייה ברוחב נוח.", "Meta · פריט שלישי קצר."];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
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
  const ForgeBulletList({super.key, this.fields, this.child, this.items});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    final Widget body = Container(padding: const EdgeInsets.fromLTRB(24, 22, 24, 22), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: _withChild(IntrinsicWidth(child: Padding(padding: const EdgeInsets.only(top: 8, bottom: 8), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [...(items == null ? <Widget>[Container(margin: const EdgeInsets.fromLTRB(0, 0, 0, 0), child: SizedBox(width: double.infinity, child: Stack(clipBehavior: Clip.none, children: [Padding(padding: const EdgeInsets.fromLTRB(0, 0, 22, 0), child: Text.rich(TextSpan(children: [TextSpan(text: _f(0, "Label"), style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 14, fontWeight: FontWeight.w600, height: 1.75, leadingDistribution: TextLeadingDistribution.even)), TextSpan(text: _f(1, " — לורם איפסום דולור סיט אמט קונסקטורר."), style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 14, height: 1.75, leadingDistribution: TextLeadingDistribution.even))]))), Positioned(top: 8.68, right: 3, width: 7, child: Container(width: 7, height: 7, decoration: BoxDecoration(color: theme.a, borderRadius: BorderRadius.circular(999))))]))), Container(margin: const EdgeInsets.fromLTRB(0, 0, 0, 0), child: SizedBox(width: double.infinity, child: Stack(clipBehavior: Clip.none, children: [Padding(padding: const EdgeInsets.fromLTRB(0, 0, 22, 0), child: Text(_f(2, "אדיפיסינג אלית, שורה שנייה ברוחב נוח."), style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 14, height: 1.75, leadingDistribution: TextLeadingDistribution.even))), Positioned(top: 8.68, right: 3, width: 7, child: Container(width: 7, height: 7, decoration: BoxDecoration(color: theme.a, borderRadius: BorderRadius.circular(999))))]))), Container(margin: const EdgeInsets.fromLTRB(0, 0, 0, 0), child: SizedBox(width: double.infinity, child: Stack(clipBehavior: Clip.none, children: [Padding(padding: const EdgeInsets.fromLTRB(0, 0, 22, 0), child: Text(_f(3, "Meta · פריט שלישי קצר."), style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 14, height: 1.75, leadingDistribution: TextLeadingDistribution.even))), Positioned(top: 8.68, right: 3, width: 7, child: Container(width: 7, height: 7, decoration: BoxDecoration(color: theme.a, borderRadius: BorderRadius.circular(999))))])))] : List<Widget>.generate(items!.length, (i) => Container(margin: const EdgeInsets.fromLTRB(0, 0, 0, 0), child: SizedBox(width: double.infinity, child: Stack(clipBehavior: Clip.none, children: [Padding(padding: const EdgeInsets.fromLTRB(0, 0, 22, 0), child: Text.rich(TextSpan(children: [TextSpan(text: _it(items![i], 0, "Label"), style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 14, fontWeight: FontWeight.w600, height: 1.75, leadingDistribution: TextLeadingDistribution.even)), TextSpan(text: _it(items![i], 1, " — לורם איפסום דולור סיט אמט קונסקטורר."), style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 14, height: 1.75, leadingDistribution: TextLeadingDistribution.even))]))), Positioned(top: 8.68, right: 3, width: 7, child: Container(width: 7, height: 7, decoration: BoxDecoration(color: theme.a, borderRadius: BorderRadius.circular(999))))])))))]))), child));
    return body;
  }
}
