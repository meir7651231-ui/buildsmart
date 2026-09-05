// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "input" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/input-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// TagInput — seam:collection · 4 חריצים
class ForgeTagInput extends StatelessWidget {
  /// תפר-דאטה (G12a): 4 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 4;
  static const List<String> fieldDemo = <String>["Label", "×", "Label", "×"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  /// G13a · תוכן-נוסף בתוך מסגרת-האטום, אחרי זרימת-העיצוב (מקטע/כרטיס ⇒ תוכן-המודול). null ⇒ האטום לבדו.
  final Widget? child;
  // G13a · תוכן-נוסף בתוך המסגרת; null ⇒ ביט-זהה. גובה-חסום (Expanded/SizedBox סביב המסגרת) ⇒ התוכן ממלא (Expanded — רשימות/גלילה חיות, כמו GlassCard(child) של הזהב); גובה-חופשי ⇒ Column מכווץ-לתוכן.
  static Widget _withChild(Widget w, Widget? c) => c == null ? w : LayoutBuilder(builder: (ctx, cns) => cns.hasBoundedHeight
      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, Expanded(child: c)])
      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, c]));
  /// G13a · שדה-חי (TextField וכו׳) במקום ציור-ה-input של הגלריה. null ⇒ הציור.
  final Widget? control;
  /// G13a · קבוצת-פריטים: items[i] = חריצי-הטקסט של פריט i (2 חריצים · 2 בדמו). null ⇒ פריטי-העיצוב.
  final List<List<String>>? items;
  static const int itemSlots = 2;
  static const int itemDemo = 2;
  String _it(List<String> r, int j, String d) => items == null ? d : (j < r.length ? r[j] : '');
  const ForgeTagInput({super.key, this.fields, this.child, this.control, this.items});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    final Widget body = Container(height: 44, alignment: Alignment.centerRight, padding: const EdgeInsets.fromLTRB(10, 7, 10, 7), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: _withChild(Wrap(spacing: 7, runSpacing: 7, crossAxisAlignment: WrapCrossAlignment.center, children: [...(items == null ? <Widget>[Container(padding: const EdgeInsets.fromLTRB(10, 4, 6, 4), decoration: BoxDecoration(color: theme.a.withValues(alpha: 0.140), border: Border.all(color: theme.a.withValues(alpha: 0.280)), borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 6, children: [Text(_f(0, "Label"), style: TextStyle(color: theme.aHi, fontFamily: fonts.he, fontSize: 12)), Text(_f(1, "×"), style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 12))])), Container(padding: const EdgeInsets.fromLTRB(10, 4, 6, 4), decoration: BoxDecoration(color: theme.a.withValues(alpha: 0.140), border: Border.all(color: theme.a.withValues(alpha: 0.280)), borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 6, children: [Text(_f(2, "Label"), style: TextStyle(color: theme.aHi, fontFamily: fonts.he, fontSize: 12)), Text(_f(3, "×"), style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 12))]))] : List<Widget>.generate(items!.length, (i) => Container(padding: const EdgeInsets.fromLTRB(10, 4, 6, 4), decoration: BoxDecoration(color: theme.a.withValues(alpha: 0.140), border: Border.all(color: theme.a.withValues(alpha: 0.280)), borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 6, children: [Text(_it(items![i], 0, "Label"), style: TextStyle(color: theme.aHi, fontFamily: fonts.he, fontSize: 12)), Text(_it(items![i], 1, "×"), style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 12))])))), (control ?? Directionality(textDirection: TextDirection.rtl, child: Container(constraints: const BoxConstraints(minHeight: 44, minWidth: 60), child: Align(alignment: Alignment.centerRight, child: Text("Add…", style: TextStyle(color: skin.faint, fontFamily: fonts.he, fontSize: 13))))))]), child));
    return body;
  }
}
