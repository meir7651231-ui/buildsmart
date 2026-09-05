// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "text" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/text-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// Marquee — seam:fields · 12 חריצים
class ForgeMarquee extends StatelessWidget {
  /// תפר-דאטה (G12a): 12 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 12;
  static const List<String> fieldDemo = <String>["LABEL · ", "PURE", " · META", "TYPE · ", "SCALE", " · VOICE", "LABEL · ", "PURE", " · META", "TYPE · ", "SCALE", " · VOICE"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  const ForgeMarquee({super.key, this.fields});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(0, 0, 0, 0), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Container(padding: const EdgeInsets.fromLTRB(0, 12, 0, 12), child: Directionality(textDirection: TextDirection.ltr, child: Container(margin: const EdgeInsets.fromLTRB(26, 0, 26, 0), child: Text.rich(TextSpan(children: [WidgetSpan(alignment: PlaceholderAlignment.middle, child: Directionality(textDirection: TextDirection.ltr, child: Text.rich(TextSpan(children: [TextSpan(text: _f(0, "LABEL · "), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 12, letterSpacing: 3)), TextSpan(text: _f(1, "PURE"), style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 12, letterSpacing: 3)), TextSpan(text: _f(2, " · META"), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 12, letterSpacing: 3))])))), WidgetSpan(alignment: PlaceholderAlignment.middle, child: Directionality(textDirection: TextDirection.ltr, child: Text.rich(TextSpan(children: [TextSpan(text: _f(3, "TYPE · "), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 12, letterSpacing: 3)), TextSpan(text: _f(4, "SCALE"), style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 12, letterSpacing: 3)), TextSpan(text: _f(5, " · VOICE"), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 12, letterSpacing: 3))])))), WidgetSpan(alignment: PlaceholderAlignment.middle, child: Directionality(textDirection: TextDirection.ltr, child: Text.rich(TextSpan(children: [TextSpan(text: _f(6, "LABEL · "), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 12, letterSpacing: 3)), TextSpan(text: _f(7, "PURE"), style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 12, letterSpacing: 3)), TextSpan(text: _f(8, " · META"), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 12, letterSpacing: 3))])))), WidgetSpan(alignment: PlaceholderAlignment.middle, child: Directionality(textDirection: TextDirection.ltr, child: Text.rich(TextSpan(children: [TextSpan(text: _f(9, "TYPE · "), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 12, letterSpacing: 3)), TextSpan(text: _f(10, "SCALE"), style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 12, letterSpacing: 3)), TextSpan(text: _f(11, " · VOICE"), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 12, letterSpacing: 3))]))))]))))));
  }
}
