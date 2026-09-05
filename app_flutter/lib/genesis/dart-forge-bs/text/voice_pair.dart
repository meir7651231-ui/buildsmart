// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "text" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/text-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// VoicePair — seam:collection · 8 חריצים
class ForgeVoicePair extends StatelessWidget {
  /// תפר-דאטה (G12a): 8 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 8;
  static const List<String> fieldDemo = <String>["LATIN · FRAUNCES", "The quiet system", "A serif display face carries the Latin headline — high contrast, optical sizing, an editorial register that reads as considered rather than default.", "Fraunces · opsz 9–144", "עברית · FRANK RUHL LIBRE", "המערכת השקטה", "פרנק-רוהל נושא את הכותרת העברית — נגזרת קלאסית, משקל אחד כבד, קול עורכי שקורא כמכוון ולא כברירת-מחדל.", "Frank Ruhl Libre · 700"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  /// G13a · תוכן-נוסף בתוך מסגרת-האטום, אחרי זרימת-העיצוב (מקטע/כרטיס ⇒ תוכן-המודול). null ⇒ האטום לבדו.
  final Widget? child;
  // G13a · תוכן-נוסף בתוך המסגרת; null ⇒ ביט-זהה. גובה-חסום (Expanded/SizedBox סביב המסגרת) ⇒ התוכן ממלא (Expanded — רשימות/גלילה חיות, כמו GlassCard(child) של הזהב); גובה-חופשי ⇒ Column מכווץ-לתוכן.
  static Widget _withChild(Widget w, Widget? c) => c == null ? w : LayoutBuilder(builder: (ctx, cns) => cns.hasBoundedHeight
      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, Expanded(child: c)])
      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, c]));
  static Widget _hide(String s, Widget w) => s.isEmpty ? const SizedBox.shrink() : w;   // G13a · חריץ-ריק ⇒ הקופסה נעלמת
  const ForgeVoicePair({super.key, this.fields, this.child});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    final Widget body = Container(decoration: BoxDecoration(color: skin.hair, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: _withChild(Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 1, children: [Container(padding: const EdgeInsets.fromLTRB(24, 24, 24, 24), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Directionality(textDirection: TextDirection.ltr, child: Text(_f(0, "LATIN · FRAUNCES"), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 9, letterSpacing: 2))), const SizedBox(height: 14), Directionality(textDirection: TextDirection.ltr, child: Text(_f(1, "The quiet system"), style: TextStyle(color: skin.ink, fontFamily: fonts.serif, fontFamilyFallback: [fonts.serifHe], fontSize: 26, fontWeight: FontWeight.w600, letterSpacing: -0.52, height: 1.08, leadingDistribution: TextLeadingDistribution.even))), const SizedBox(height: 12), _hide(_f(2, "A serif display face carries the Latin headline — high contrast, optical sizing, an editorial register that reads as considered rather than default."), IntrinsicWidth(child: Text(_f(2, "A serif display face carries the Latin headline — high contrast, optical sizing, an editorial register that reads as considered rather than default."), style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 13, height: 1.65, leadingDistribution: TextLeadingDistribution.even)))), const SizedBox(height: 14), Directionality(textDirection: TextDirection.ltr, child: Text(_f(3, "Fraunces · opsz 9–144"), style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 10, letterSpacing: 0.5)))])), Container(padding: const EdgeInsets.fromLTRB(24, 24, 24, 24), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Directionality(textDirection: TextDirection.ltr, child: Text(_f(4, "עברית · FRANK RUHL LIBRE"), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 9, letterSpacing: 2))), const SizedBox(height: 14), Text(_f(5, "המערכת השקטה"), style: TextStyle(color: skin.ink, fontFamily: fonts.serifHe, fontSize: 26, fontWeight: FontWeight.w700, height: 1.15, leadingDistribution: TextLeadingDistribution.even)), const SizedBox(height: 12), _hide(_f(6, "פרנק-רוהל נושא את הכותרת העברית — נגזרת קלאסית, משקל אחד כבד, קול עורכי שקורא כמכוון ולא כברירת-מחדל."), IntrinsicWidth(child: Text(_f(6, "פרנק-רוהל נושא את הכותרת העברית — נגזרת קלאסית, משקל אחד כבד, קול עורכי שקורא כמכוון ולא כברירת-מחדל."), style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 13, height: 1.65, leadingDistribution: TextLeadingDistribution.even)))), const SizedBox(height: 14), Directionality(textDirection: TextDirection.ltr, child: Text(_f(7, "Frank Ruhl Libre · 700"), style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 10, letterSpacing: 0.5)))]))]), child));
    return body;
  }
}
