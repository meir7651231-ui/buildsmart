// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "list" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/list-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// NotifRow — seam:fields · 7 חריצים
class ForgeNotifRow extends StatelessWidget {
  /// תפר-דאטה (G12a): 7 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 7;
  static const List<String> fieldDemo = <String>["Label", "Meta", "Label", "Meta", "3", "Label", "Meta"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
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
  const ForgeNotifRow({super.key, this.fields, this.child, this.items});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    final Widget body = Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(15)), child: _withChild(Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [...(items == null ? <Widget>[Container(constraints: const BoxConstraints(minHeight: 52), padding: const EdgeInsets.fromLTRB(15, 12, 15, 12), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: skin.hair, width: 1))), child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 12, children: [Container(width: 9, height: 9, decoration: BoxDecoration(color: skin.ok, borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: skin.ok, offset: const Offset(0, 0), blurRadius: 0, spreadRadius: 3)])), Expanded(child: Text.rich(TextSpan(children: [TextSpan(text: _f(0, "Label"), style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 13.5, fontWeight: FontWeight.w600, height: 1.25, leadingDistribution: TextLeadingDistribution.even)), TextSpan(text: _f(1, "Meta"), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11))]))), Container(width: 8, height: 8, decoration: BoxDecoration(color: theme.a, borderRadius: BorderRadius.circular(999)))])), Container(constraints: const BoxConstraints(minHeight: 52), padding: const EdgeInsets.fromLTRB(15, 12, 15, 12), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: skin.hair, width: 1))), child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 12, children: [Container(width: 9, height: 9, decoration: BoxDecoration(color: skin.warn, borderRadius: BorderRadius.circular(999))), Expanded(child: Text.rich(TextSpan(children: [TextSpan(text: _f(2, "Label"), style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 13.5, fontWeight: FontWeight.w600, height: 1.25, leadingDistribution: TextLeadingDistribution.even)), TextSpan(text: _f(3, "Meta"), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11))]))), Flexible(child: Directionality(textDirection: TextDirection.ltr, child: Text(_f(4, "3"), style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis, softWrap: false)))])), Container(constraints: const BoxConstraints(minHeight: 52), padding: const EdgeInsets.fromLTRB(15, 12, 15, 12), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: skin.hair, width: 1))), child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 12, children: [Container(width: 9, height: 9, decoration: BoxDecoration(color: skin.faint, borderRadius: BorderRadius.circular(999))), Expanded(child: Text.rich(TextSpan(children: [TextSpan(text: _f(5, "Label"), style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 13.5, fontWeight: FontWeight.w600, height: 1.25, leadingDistribution: TextLeadingDistribution.even)), TextSpan(text: _f(6, "Meta"), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11))])))]))] : List<Widget>.generate(items!.length, (i) => Container(constraints: const BoxConstraints(minHeight: 52), padding: const EdgeInsets.fromLTRB(15, 12, 15, 12), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: skin.hair, width: 1))), child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 12, children: [Container(width: 9, height: 9, decoration: BoxDecoration(color: skin.ok, borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: skin.ok, offset: const Offset(0, 0), blurRadius: 0, spreadRadius: 3)])), Expanded(child: Text.rich(TextSpan(children: [TextSpan(text: _it(items![i], 0, "Label"), style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 13.5, fontWeight: FontWeight.w600, height: 1.25, leadingDistribution: TextLeadingDistribution.even)), TextSpan(text: _it(items![i], 1, "Meta"), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11))]))), Container(width: 8, height: 8, decoration: BoxDecoration(color: theme.a, borderRadius: BorderRadius.circular(999)))]))))]), child));
    return body;
  }
}
