// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "input" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/input-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// SmartQtyStepper — seam:fields · 6 חריצים
class ForgeSmartQtyStepper extends StatelessWidget {
  /// תפר-דאטה (G12a): 6 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 6;
  static const List<String> fieldDemo = <String>["−", "1", "+", "+5", "+10", "Max"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  /// G13a · תוכן-נוסף בתוך מסגרת-האטום, אחרי זרימת-העיצוב (מקטע/כרטיס ⇒ תוכן-המודול). null ⇒ האטום לבדו.
  final Widget? child;
  // G13a · תוכן-נוסף בתוך המסגרת; null ⇒ ביט-זהה. גובה-חסום (Expanded/SizedBox סביב המסגרת) ⇒ התוכן ממלא (Expanded — רשימות/גלילה חיות, כמו GlassCard(child) של הזהב); גובה-חופשי ⇒ Column מכווץ-לתוכן.
  static Widget _withChild(Widget w, Widget? c) => c == null ? w : LayoutBuilder(builder: (ctx, cns) => cns.hasBoundedHeight
      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, Expanded(child: c)])
      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, c]));
  static Widget _hide(String s, Widget w) => s.isEmpty ? const SizedBox.shrink() : w;   // G13a · חריץ-ריק ⇒ הקופסה נעלמת
  /// G13a · הקשה על כפתור/קישור k (סדר-הופעה, 2 פעולות).
  final void Function(int)? onAction;
  static const int actionSlots = 2;
  /// G13a · קבוצת-פריטים: items[i] = חריצי-הטקסט של פריט i (1 חריצים · 3 בדמו). null ⇒ פריטי-העיצוב.
  final List<List<String>>? items;
  static const int itemSlots = 1;
  static const int itemDemo = 3;
  String _it(List<String> r, int j, String d) => items == null ? d : (j < r.length ? r[j] : '');
  const ForgeSmartQtyStepper({super.key, this.fields, this.child, this.onAction, this.items});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    final Widget body = _withChild(Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 8, children: [Container(decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [GestureDetector(behavior: HitTestBehavior.opaque, onTap: onAction == null ? null : () => onAction!(0), child: _hide(_f(0, "−"), Container(width: 42, height: 44, alignment: Alignment.center, child: Text(_f(0, "−"), style: TextStyle(color: skin.ink, fontSize: 18, fontFamily: fonts.he))))), _hide(_f(1, "1"), Directionality(textDirection: TextDirection.ltr, child: Container(constraints: const BoxConstraints(minWidth: 46), child: Text(_f(1, "1"), textAlign: TextAlign.center, style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 16, fontWeight: FontWeight.w600))))), GestureDetector(behavior: HitTestBehavior.opaque, onTap: onAction == null ? null : () => onAction!(1), child: _hide(_f(2, "+"), Container(width: 42, height: 44, alignment: Alignment.center, child: Text(_f(2, "+"), style: TextStyle(color: skin.ink, fontSize: 18, fontFamily: fonts.he)))))])), Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 6, children: [...(items == null ? <Widget>[_hide(_f(3, "+5"), Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(10, 4, 10, 4), decoration: BoxDecoration(color: theme.a.withValues(alpha: 0.120), border: Border.all(color: theme.a.withValues(alpha: 0.300)), borderRadius: BorderRadius.circular(999)), child: Text(_f(3, "+5"), style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11))))), _hide(_f(4, "+10"), Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(10, 4, 10, 4), decoration: BoxDecoration(color: theme.a.withValues(alpha: 0.120), border: Border.all(color: theme.a.withValues(alpha: 0.300)), borderRadius: BorderRadius.circular(999)), child: Text(_f(4, "+10"), style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11))))), _hide(_f(5, "Max"), Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(10, 4, 10, 4), decoration: BoxDecoration(color: theme.a.withValues(alpha: 0.120), border: Border.all(color: theme.a.withValues(alpha: 0.300)), borderRadius: BorderRadius.circular(999)), child: Text(_f(5, "Max"), style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11)))))] : List<Widget>.generate(items!.length, (i) => Flexible(child: _hide(_it(items![i], 0, "+5"), Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(10, 4, 10, 4), decoration: BoxDecoration(color: theme.a.withValues(alpha: 0.120), border: Border.all(color: theme.a.withValues(alpha: 0.300)), borderRadius: BorderRadius.circular(999)), child: Text(_it(items![i], 0, "+5"), style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11))))))))])]), child);
    return body;
  }
}
