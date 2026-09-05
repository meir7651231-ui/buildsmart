// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "media" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/media-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// AvatarStack — seam:collection · 4 חריצים
class ForgeAvatarStack extends StatelessWidget {
  /// תפר-דאטה (G12a): 4 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 4;
  static const List<String> fieldDemo = <String>["L", "L", "L", "+8"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  /// G13a · תוכן-נוסף בתוך מסגרת-האטום, אחרי זרימת-העיצוב (מקטע/כרטיס ⇒ תוכן-המודול). null ⇒ האטום לבדו.
  final Widget? child;
  // G13a · תוכן-נוסף בתוך המסגרת; null ⇒ ביט-זהה. גובה-חסום (Expanded/SizedBox סביב המסגרת) ⇒ התוכן ממלא (Expanded — רשימות/גלילה חיות, כמו GlassCard(child) של הזהב); גובה-חופשי ⇒ Column מכווץ-לתוכן.
  static Widget _withChild(Widget w, Widget? c) => c == null ? w : LayoutBuilder(builder: (ctx, cns) => cns.hasBoundedHeight
      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, Expanded(child: c)])
      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, c]));
  static Widget _hide(String s, Widget w) => s.isEmpty ? const SizedBox.shrink() : w;   // G13a · חריץ-ריק ⇒ הקופסה נעלמת
  const ForgeAvatarStack({super.key, this.fields, this.child});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    final Widget body = Container(height: 88, alignment: Alignment.centerRight, child: Wrap(spacing: 14, runSpacing: 14, crossAxisAlignment: WrapCrossAlignment.center, children: [_withChild(SizedBox(width: 94, height: 34, child: Stack(clipBehavior: Clip.none, children: [Positioned(right: 0, top: 0, bottom: 0, child: Center(widthFactor: 1.0, child: _hide(_f(0, "L"), Container(width: 34, height: 34, alignment: Alignment.center, margin: const EdgeInsets.fromLTRB(0, 0, 0, 0), decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: skin.canvas, offset: const Offset(0, 0), blurRadius: 0, spreadRadius: 2.5)]), child: Text(_f(0, "L"), style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 13.6, fontWeight: FontWeight.w700, height: 1, leadingDistribution: TextLeadingDistribution.even)))))), Positioned(right: 20, top: 0, bottom: 0, child: Center(widthFactor: 1.0, child: _hide(_f(1, "L"), Container(width: 34, height: 34, alignment: Alignment.center, margin: const EdgeInsets.fromLTRB(0, 0, 0, 0), decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.c2, theme.a, theme.c3], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: skin.canvas, offset: const Offset(0, 0), blurRadius: 0, spreadRadius: 2.5)]), child: Text(_f(1, "L"), style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 13.6, fontWeight: FontWeight.w700, height: 1, leadingDistribution: TextLeadingDistribution.even)))))), Positioned(right: 40, top: 0, bottom: 0, child: Center(widthFactor: 1.0, child: _hide(_f(2, "L"), Container(width: 34, height: 34, alignment: Alignment.center, margin: const EdgeInsets.fromLTRB(0, 0, 0, 0), decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: skin.canvas, offset: const Offset(0, 0), blurRadius: 0, spreadRadius: 2.5)]), child: Text(_f(2, "L"), style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 13.6, fontWeight: FontWeight.w700, height: 1, leadingDistribution: TextLeadingDistribution.even)))))), Positioned(right: 60, top: 0, bottom: 0, child: Center(widthFactor: 1.0, child: _hide(_f(3, "+8"), Directionality(textDirection: TextDirection.ltr, child: Container(width: 34, height: 34, alignment: Alignment.center, margin: const EdgeInsets.fromLTRB(0, 0, 0, 0), decoration: BoxDecoration(color: skin.raised2, borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: skin.canvas, offset: const Offset(0, 0), blurRadius: 0, spreadRadius: 2.5)]), child: Text(_f(3, "+8"), style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 12, fontWeight: FontWeight.w700)))))))])), child)]));
    return body;
  }
}
