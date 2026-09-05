// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "text" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/text-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// PullQuote — seam:fields · 4 חריצים
class ForgePullQuote extends StatelessWidget {
  /// תפר-דאטה (G12a): 4 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 4;
  static const List<String> fieldDemo = <String>["”", "הטיפוגרפיה היא הקול של הממשק לפני שאמרנו מילה — הסולם, המשקל והמרווח מכריעים מה נקרא ראשון.", "“", "META · LABEL"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  const ForgePullQuote({super.key, this.fields});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(24, 22, 24, 22), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: IntrinsicWidth(child: Container(padding: const EdgeInsets.fromLTRB(24, 8, 24, 8), decoration: BoxDecoration(border: Border(right: BorderSide(color: theme.a, width: 3))), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text.rich(TextSpan(children: [TextSpan(text: _f(0, "”"), style: TextStyle(color: theme.aHi, fontFamily: fonts.serifHe, fontSize: 21, fontWeight: FontWeight.w700, height: 1.32, leadingDistribution: TextLeadingDistribution.even)), TextSpan(text: _f(1, "הטיפוגרפיה היא הקול של הממשק לפני שאמרנו מילה — הסולם, המשקל והמרווח מכריעים מה נקרא ראשון."), style: TextStyle(color: skin.ink, fontFamily: fonts.serifHe, fontSize: 21, fontWeight: FontWeight.w700, height: 1.32, leadingDistribution: TextLeadingDistribution.even)), TextSpan(text: _f(2, "“"), style: TextStyle(color: theme.aHi, fontFamily: fonts.serifHe, fontSize: 21, fontWeight: FontWeight.w700, height: 1.32, leadingDistribution: TextLeadingDistribution.even))])), const SizedBox(height: 14), Directionality(textDirection: TextDirection.ltr, child: Text(_f(3, "META · LABEL"), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11, letterSpacing: 1.5)))]))));
  }
}
