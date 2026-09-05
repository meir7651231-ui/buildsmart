// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "spatial" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/spatial-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// DataGrid — seam:collection · 12 חריצים
class ForgeDataGrid extends StatelessWidget {
  /// תפר-דאטה (G12a): 12 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 12;
  static const List<String> fieldDemo = <String>["LABEL", "LABEL", "LABEL", "Label", "248", "Meta", "Label", "1,024", "Meta", "Label", "92", "Meta"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  /// G13a · תוכן-נוסף בתוך מסגרת-האטום, אחרי זרימת-העיצוב (מקטע/כרטיס ⇒ תוכן-המודול). null ⇒ האטום לבדו.
  final Widget? child;
  // G13a · תוכן-נוסף בתוך המסגרת; null ⇒ ביט-זהה. גובה-חסום (Expanded/SizedBox סביב המסגרת) ⇒ התוכן ממלא (Expanded — רשימות/גלילה חיות, כמו GlassCard(child) של הזהב); גובה-חופשי ⇒ Column מכווץ-לתוכן.
  static Widget _withChild(Widget w, Widget? c) => c == null ? w : LayoutBuilder(builder: (ctx, cns) => cns.hasBoundedHeight
      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, Expanded(child: c)])
      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, c]));
  /// G13b · bare=true ⇒ ליבת-הבקרה בלי מסגרת-הגלריה של Pure (.ctl/.body/.stage); child נכנס לליבה. false ⇒ ביט-זהה לגלריה.
  final bool bare;
  /// G13d · כותרות-עמודות: columns[j] ⇒ תבנית-הכותרת (3 בדמו). null ⇒ כותרות-העיצוב.
  final List<String>? columns;
  /// G13a · קבוצת-פריטים: items[i] = חריצי-הטקסט של פריט i (3 חריצים · 3 בדמו · תאים: items[i].length (3 בדמו)). null ⇒ פריטי-העיצוב.
  final List<List<String>>? items;
  static const int itemSlots = 3;
  static const int itemDemo = 3;
  String _it(List<String> r, int j, String d) => items == null ? d : (j < r.length ? r[j] : '');
  const ForgeDataGrid({super.key, this.fields, this.child, this.bare = false, this.items, this.columns});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    final Widget core = Container(decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(12)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(13, 0, 13, 0), decoration: BoxDecoration(color: skin.surface, border: Border(bottom: BorderSide(color: skin.hair, width: 1))), child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 10, children: [...(columns == null ? <Widget>[Expanded(child: Text(_f(0, "LABEL"), style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: 0.76))), Expanded(child: Text(_f(1, "LABEL"), style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: 0.76))), Expanded(child: Text(_f(2, "LABEL"), style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: 0.76)))] : List<Widget>.generate(columns!.length, (j) => Expanded(child: Text((j < columns!.length ? columns![j] : "LABEL"), style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: 0.76)))))])), ...(items == null ? <Widget>[Container(constraints: const BoxConstraints(minHeight: 42), padding: const EdgeInsets.fromLTRB(13, 0, 13, 0), decoration: BoxDecoration(border: Border(top: BorderSide(color: skin.hair2, width: 1))), child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 10, children: [Expanded(child: Text(_f(3, "Label"), style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 12.5))), Expanded(child: Text(_f(4, "248"), style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 12.5))), Expanded(child: Text(_f(5, "Meta"), style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 12.5)))])), Container(constraints: const BoxConstraints(minHeight: 42), padding: const EdgeInsets.fromLTRB(13, 0, 13, 0), decoration: BoxDecoration(border: Border(top: BorderSide(color: skin.hair2, width: 1))), child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 10, children: [Expanded(child: Text(_f(6, "Label"), style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 12.5))), Expanded(child: Text(_f(7, "1,024"), style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 12.5))), Expanded(child: Text(_f(8, "Meta"), style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 12.5)))])), Container(constraints: const BoxConstraints(minHeight: 42), padding: const EdgeInsets.fromLTRB(13, 0, 13, 0), decoration: BoxDecoration(border: Border(top: BorderSide(color: skin.hair2, width: 1))), child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 10, children: [Expanded(child: Text(_f(9, "Label"), style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 12.5))), Expanded(child: Text(_f(10, "92"), style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 12.5))), Expanded(child: Text(_f(11, "Meta"), style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 12.5)))]))] : List<Widget>.generate(items!.length, (i) => Container(constraints: const BoxConstraints(minHeight: 42), padding: const EdgeInsets.fromLTRB(13, 0, 13, 0), decoration: BoxDecoration(border: Border(top: BorderSide(color: skin.hair2, width: 1))), child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 10, children: [...List<Widget>.generate(items![i].length, (j) => Expanded(child: Text(_it(items![i], j, "Label"), style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 12.5))))]))))]));
    final Widget body = bare ? _withChild(core, child) : Container(padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), child: _withChild(core, child));
    return body;
  }
}
