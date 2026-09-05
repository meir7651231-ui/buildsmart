// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "card" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/card-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// StatusDot — seam:fields · 3 חריצים
class ForgeStatusDot extends StatelessWidget {
  /// תפר-דאטה (G12a): 3 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 3;
  static const List<String> fieldDemo = <String>["Label", "Label", "Label"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
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
  const ForgeStatusDot({super.key, this.fields, this.child, this.items});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    final Widget body = Container(padding: const EdgeInsets.fromLTRB(2, 10, 2, 10), child: _withChild(Wrap(spacing: 14, runSpacing: 14, crossAxisAlignment: WrapCrossAlignment.center, children: [...(items == null ? <Widget>[Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 8, children: [Container(width: 9, height: 9, decoration: BoxDecoration(color: skin.ok, borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: skin.ok, offset: const Offset(0, 0), blurRadius: 0, spreadRadius: 3)])), Text(_f(0, "Label"), style: TextStyle(color: skin.mut, fontSize: 12, fontFamily: fonts.he))]), Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 8, children: [Container(width: 9, height: 9, decoration: BoxDecoration(color: skin.faint, borderRadius: BorderRadius.circular(999))), Text(_f(1, "Label"), style: TextStyle(color: skin.mut, fontSize: 12, fontFamily: fonts.he))]), Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 8, children: [Container(width: 9, height: 9, decoration: BoxDecoration(color: skin.warn, borderRadius: BorderRadius.circular(999))), Text(_f(2, "Label"), style: TextStyle(color: skin.mut, fontSize: 12, fontFamily: fonts.he))])] : List<Widget>.generate(items!.length, (i) => Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 8, children: [Container(width: 9, height: 9, decoration: BoxDecoration(color: skin.ok, borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: skin.ok, offset: const Offset(0, 0), blurRadius: 0, spreadRadius: 3)])), Text(_it(items![i], 0, "Label"), style: TextStyle(color: skin.mut, fontSize: 12, fontFamily: fonts.he))])))]), child));
    return body;
  }
}
