// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "selection" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/selection-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// DsChip — seam:series · 6 חריצים
class ForgeDsChip extends StatelessWidget {
  /// תפר-דאטה (G12a): 6 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 6;
  static const List<String> fieldDemo = <String>["Label", "Label", "Label", "Label", "Label", "Value 248"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  /// G13a · תוכן-נוסף בתוך מסגרת-האטום, אחרי זרימת-העיצוב (מקטע/כרטיס ⇒ תוכן-המודול). null ⇒ האטום לבדו.
  final Widget? child;
  // G13a · תוכן-נוסף בתוך המסגרת; null ⇒ ביט-זהה. גובה-חסום (Expanded/SizedBox סביב המסגרת) ⇒ התוכן ממלא (Expanded — רשימות/גלילה חיות, כמו GlassCard(child) של הזהב); גובה-חופשי ⇒ Column מכווץ-לתוכן.
  static Widget _withChild(Widget w, Widget? c) => c == null ? w : LayoutBuilder(builder: (ctx, cns) => cns.hasBoundedHeight
      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, Expanded(child: c)])
      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, c]));
  static Widget _hide(String s, Widget w) => s.isEmpty ? const SizedBox.shrink() : w;   // G13a · חריץ-ריק ⇒ הקופסה נעלמת
  /// G13b · bare=true ⇒ ליבת-הבקרה בלי מסגרת-הגלריה של Pure (.ctl/.body/.stage); child נכנס לליבה. false ⇒ ביט-זהה לגלריה.
  final bool bare;
  /// G13a · קבוצת-פריטים: items[i] = חריצי-הטקסט של פריט i (1 חריצים · 2 בדמו · selected = הפריטים-הפעילים). null ⇒ פריטי-העיצוב.
  final List<List<String>>? items;
  final Set<int>? selected;
  static const int itemSlots = 1;
  static const int itemDemo = 2;
  String _it(List<String> r, int j, String d) => items == null ? d : (j < r.length ? r[j] : '');
  const ForgeDsChip({super.key, this.fields, this.child, this.bare = false, this.items, this.selected});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    final Widget core = Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [...(items == null ? <Widget>[_hide(_f(0, "Label"), Directionality(textDirection: TextDirection.ltr, child: Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(13, 7, 13, 7), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Text(_f(0, "Label"), style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11, fontWeight: FontWeight.w600))))), _hide(_f(1, "Label"), Directionality(textDirection: TextDirection.ltr, child: Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(13, 7, 13, 7), decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Text(_f(1, "Label"), style: TextStyle(color: const Color(0xFF0A0A0C), fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11, fontWeight: FontWeight.w600)))))] : List<Widget>.generate(items!.length, (i) => ((selected?.contains(i) ?? false) ? _hide(_it(items![i], 0, "Label"), Directionality(textDirection: TextDirection.ltr, child: Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(13, 7, 13, 7), decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Text(_it(items![i], 0, "Label"), style: TextStyle(color: const Color(0xFF0A0A0C), fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11, fontWeight: FontWeight.w600))))) : _hide(_it(items![i], 0, "Label"), Directionality(textDirection: TextDirection.ltr, child: Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(13, 7, 13, 7), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Text(_it(items![i], 0, "Label"), style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11, fontWeight: FontWeight.w600)))))))), Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(9, 3, 9, 3), decoration: BoxDecoration(color: skin.ok.withValues(alpha: 0.140), border: Border.all(color: skin.ok.withValues(alpha: 0.300)), borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 5, children: [Container(width: 6, height: 6, decoration: BoxDecoration(borderRadius: BorderRadius.circular(999))), Text(_f(2, "Label"), style: TextStyle(color: skin.ok, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 10, fontWeight: FontWeight.w700))]))), _hide(_f(3, "Label"), Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(9, 3, 9, 3), decoration: BoxDecoration(color: skin.warn.withValues(alpha: 0.140), border: Border.all(color: skin.warn.withValues(alpha: 0.300)), borderRadius: BorderRadius.circular(999)), child: Text(_f(3, "Label"), style: TextStyle(color: skin.warn, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 10, fontWeight: FontWeight.w700))))), _hide(_f(4, "Label"), Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(9, 3, 9, 3), decoration: BoxDecoration(color: skin.err.withValues(alpha: 0.140), border: Border.all(color: skin.err.withValues(alpha: 0.300)), borderRadius: BorderRadius.circular(999)), child: Text(_f(4, "Label"), style: TextStyle(color: skin.err, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 10, fontWeight: FontWeight.w700))))), _hide(_f(5, "Value 248"), Directionality(textDirection: TextDirection.ltr, child: Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(13, 7, 13, 7), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Text(_f(5, "Value 248"), style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11, fontWeight: FontWeight.w600)))))]);
    final Widget body = bare ? _withChild(core, child) : Container(constraints: const BoxConstraints(minHeight: 130), padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(15)), child: _withChild(Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 8, children: [core]), child));
    return body;
  }
}
