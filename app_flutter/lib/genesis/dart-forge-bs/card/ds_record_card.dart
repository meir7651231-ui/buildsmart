// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "card" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/card-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// DsRecordCard — seam:fields · 8 חריצים
class ForgeDsRecordCard extends StatelessWidget {
  /// תפר-דאטה (G12a): 8 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 8;
  static const List<String> fieldDemo = <String>["L", "Label", "Meta", "LIVE", "Label", "248", "Label", "1,024"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  /// G13a · תוכן-נוסף בתוך מסגרת-האטום, אחרי זרימת-העיצוב (מקטע/כרטיס ⇒ תוכן-המודול). null ⇒ האטום לבדו.
  final Widget? child;
  // G13a · תוכן-נוסף בתוך המסגרת; null ⇒ ביט-זהה. גובה-חסום (Expanded/SizedBox סביב המסגרת) ⇒ התוכן ממלא (Expanded — רשימות/גלילה חיות, כמו GlassCard(child) של הזהב); גובה-חופשי ⇒ Column מכווץ-לתוכן.
  static Widget _withChild(Widget w, Widget? c) => c == null ? w : LayoutBuilder(builder: (ctx, cns) => cns.hasBoundedHeight
      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, Expanded(child: c)])
      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, c]));
  static Widget _hide(String s, Widget w) => s.isEmpty ? const SizedBox.shrink() : w;   // G13a · חריץ-ריק ⇒ הקופסה נעלמת
  /// G13a · קבוצת-פריטים: items[i] = חריצי-הטקסט של פריט i (2 חריצים · 2 בדמו). null ⇒ פריטי-העיצוב.
  final List<List<String>>? items;
  static const int itemSlots = 2;
  static const int itemDemo = 2;
  String _it(List<String> r, int j, String d) => items == null ? d : (j < r.length ? r[j] : '');
  const ForgeDsRecordCard({super.key, this.fields, this.child, this.items});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    final Widget body = Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(15)), child: _withChild(Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.fromLTRB(15, 14, 15, 14), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: skin.hair, width: 1))), child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 11, children: [_hide(_f(0, "L"), Container(width: 40, height: 40, alignment: Alignment.center, decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(11)), child: Text(_f(0, "L"), style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 16, fontWeight: FontWeight.w700)))), Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_f(1, "Label"), style: TextStyle(color: skin.ink, fontSize: 13.5, fontWeight: FontWeight.w600, fontFamily: fonts.he)), Directionality(textDirection: TextDirection.ltr, child: Text(_f(2, "Meta"), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11)))])), _hide(_f(3, "LIVE"), Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(7, 2, 7, 2), decoration: BoxDecoration(color: skin.ok.withValues(alpha: 0.140), border: Border.all(color: skin.ok.withValues(alpha: 0.300)), borderRadius: BorderRadius.circular(999)), child: Text(_f(3, "LIVE"), style: TextStyle(color: skin.ok, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 9, fontWeight: FontWeight.w700)))))])), Container(padding: const EdgeInsets.fromLTRB(15, 6, 15, 12), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [...(items == null ? <Widget>[Container(padding: const EdgeInsets.fromLTRB(0, 7, 0, 7), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: skin.hair2, width: 1))), child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [Flexible(child: Text(_f(4, "Label"), style: TextStyle(color: skin.mut, fontSize: 12.5, fontFamily: fonts.he), overflow: TextOverflow.ellipsis, softWrap: false)), Flexible(child: Directionality(textDirection: TextDirection.ltr, child: Text(_f(5, "248"), style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 12.5), overflow: TextOverflow.ellipsis, softWrap: false)))])), Container(padding: const EdgeInsets.fromLTRB(0, 7, 0, 7), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: skin.hair2, width: 1))), child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [Flexible(child: Text(_f(6, "Label"), style: TextStyle(color: skin.mut, fontSize: 12.5, fontFamily: fonts.he), overflow: TextOverflow.ellipsis, softWrap: false)), Flexible(child: Directionality(textDirection: TextDirection.ltr, child: Text(_f(7, "1,024"), style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 12.5), overflow: TextOverflow.ellipsis, softWrap: false)))]))] : List<Widget>.generate(items!.length, (i) => Container(padding: const EdgeInsets.fromLTRB(0, 7, 0, 7), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: skin.hair2, width: 1))), child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [Flexible(child: Text(_it(items![i], 0, "Label"), style: TextStyle(color: skin.mut, fontSize: 12.5, fontFamily: fonts.he), overflow: TextOverflow.ellipsis, softWrap: false)), Flexible(child: Directionality(textDirection: TextDirection.ltr, child: Text(_it(items![i], 1, "248"), style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 12.5), overflow: TextOverflow.ellipsis, softWrap: false)))]))))]))]), child));
    return body;
  }
}
