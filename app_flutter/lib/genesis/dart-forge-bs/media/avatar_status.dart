// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "media" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/media-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// AvatarStatus — seam:fields · 3 חריצים
class ForgeAvatarStatus extends StatelessWidget {
  /// תפר-דאטה (G12a): 3 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 3;
  static const List<String> fieldDemo = <String>["L", "L", "L"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  /// G13a · תוכן-נוסף בתוך מסגרת-האטום, אחרי זרימת-העיצוב (מקטע/כרטיס ⇒ תוכן-המודול). null ⇒ האטום לבדו.
  final Widget? child;
  // G13a · תוכן-נוסף בתוך המסגרת; null ⇒ ביט-זהה. גובה-חסום (Expanded/SizedBox סביב המסגרת) ⇒ התוכן ממלא (Expanded — רשימות/גלילה חיות, כמו GlassCard(child) של הזהב); גובה-חופשי ⇒ Column מכווץ-לתוכן.
  static Widget _withChild(Widget w, Widget? c) => c == null ? w : LayoutBuilder(builder: (ctx, cns) => cns.hasBoundedHeight
      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, Expanded(child: c)])
      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, c]));
  static Widget _hide(String s, Widget w) => s.isEmpty ? const SizedBox.shrink() : w;   // G13a · חריץ-ריק ⇒ הקופסה נעלמת
  /// G13a · קבוצת-פריטים: items[i] = חריצי-הטקסט של פריט i (1 חריצים · 3 בדמו). null ⇒ פריטי-העיצוב.
  final List<List<String>>? items;
  static const int itemSlots = 1;
  static const int itemDemo = 3;
  String _it(List<String> r, int j, String d) => items == null ? d : (j < r.length ? r[j] : '');
  const ForgeAvatarStatus({super.key, this.fields, this.child, this.items});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    final Widget body = Container(height: 88, alignment: Alignment.centerRight, child: _withChild(Wrap(spacing: 14, runSpacing: 14, crossAxisAlignment: WrapCrossAlignment.center, children: [...(items == null ? <Widget>[_hide(_f(0, "L"), Stack(clipBehavior: Clip.none, children: [_hide(_f(0, "L"), Container(width: 44, height: 44, alignment: Alignment.center, decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(999)), child: Text(_f(0, "L"), style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 17.6, fontWeight: FontWeight.w700, height: 1, leadingDistribution: TextLeadingDistribution.even)))), Positioned(bottom: -2, left: -2, width: 14, child: Container(width: 14, height: 14, decoration: BoxDecoration(color: skin.ok, border: Border.all(color: skin.canvas, width: 2.5), borderRadius: BorderRadius.circular(999))))])), _hide(_f(1, "L"), Stack(clipBehavior: Clip.none, children: [_hide(_f(1, "L"), Container(width: 44, height: 44, alignment: Alignment.center, decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(999)), child: Text(_f(1, "L"), style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 17.6, fontWeight: FontWeight.w700, height: 1, leadingDistribution: TextLeadingDistribution.even)))), Positioned(bottom: -2, left: -2, width: 14, child: Container(width: 14, height: 14, decoration: BoxDecoration(color: skin.warn, border: Border.all(color: skin.canvas, width: 2.5), borderRadius: BorderRadius.circular(999))))])), _hide(_f(2, "L"), Stack(clipBehavior: Clip.none, children: [_hide(_f(2, "L"), Container(width: 44, height: 44, alignment: Alignment.center, decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(999)), child: Text(_f(2, "L"), style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 17.6, fontWeight: FontWeight.w700, height: 1, leadingDistribution: TextLeadingDistribution.even)))), Positioned(bottom: -2, left: -2, width: 14, child: Container(width: 14, height: 14, decoration: BoxDecoration(color: skin.faint, border: Border.all(color: skin.canvas, width: 2.5), borderRadius: BorderRadius.circular(999))))]))] : List<Widget>.generate(items!.length, (i) => _hide(_it(items![i], 0, "L"), Stack(clipBehavior: Clip.none, children: [_hide(_it(items![i], 0, "L"), Container(width: 44, height: 44, alignment: Alignment.center, decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(999)), child: Text(_it(items![i], 0, "L"), style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 17.6, fontWeight: FontWeight.w700, height: 1, leadingDistribution: TextLeadingDistribution.even)))), Positioned(bottom: -2, left: -2, width: 14, child: Container(width: 14, height: 14, decoration: BoxDecoration(color: skin.ok, border: Border.all(color: skin.canvas, width: 2.5), borderRadius: BorderRadius.circular(999))))]))))]), child));
    return body;
  }
}
