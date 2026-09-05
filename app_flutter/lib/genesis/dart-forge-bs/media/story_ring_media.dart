// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "media" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/media-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// StoryRing — seam:fields · 2 חריצים
class ForgeStoryRingMedia extends StatelessWidget {
  /// תפר-דאטה (G12a): 2 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 2;
  static const List<String> fieldDemo = <String>["L", "L"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  const ForgeStoryRingMedia({super.key, this.fields});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(height: 88, alignment: Alignment.centerRight, child: Wrap(spacing: 14, runSpacing: 14, crossAxisAlignment: WrapCrossAlignment.center, children: [Container(width: 66, height: 66, alignment: Alignment.center, decoration: BoxDecoration(gradient: SweepGradient(colors: [theme.aHi, theme.c2, theme.c3, theme.a, theme.aHi], transform: const GradientRotation(2.0944)), borderRadius: BorderRadius.circular(999)), child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [Positioned.fill(child: Container(padding: const EdgeInsets.fromLTRB(3, 3, 3, 3), decoration: BoxDecoration(gradient: SweepGradient(colors: [theme.aHi, theme.c2, theme.c3, theme.a, theme.aHi], transform: const GradientRotation(2.0944)), borderRadius: BorderRadius.circular(999)))), Positioned.fill(child: Container(decoration: BoxDecoration(color: skin.canvas, borderRadius: BorderRadius.circular(999)))), Padding(padding: const EdgeInsets.fromLTRB(3, 3, 3, 3), child: Container(width: 54, height: 54, alignment: Alignment.center, decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(999)), child: Text(_f(0, "L"), style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 21.6, fontWeight: FontWeight.w700, height: 1, leadingDistribution: TextLeadingDistribution.even))))])), Container(width: 66, height: 66, alignment: Alignment.center, decoration: BoxDecoration(gradient: SweepGradient(colors: [theme.aHi, theme.c2, theme.c3, theme.a, theme.aHi], transform: const GradientRotation(2.0944)), borderRadius: BorderRadius.circular(999)), child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [Positioned.fill(child: Container(padding: const EdgeInsets.fromLTRB(3, 3, 3, 3), decoration: BoxDecoration(gradient: SweepGradient(colors: [theme.aHi, theme.c2, theme.c3, theme.a, theme.aHi], transform: const GradientRotation(2.0944)), borderRadius: BorderRadius.circular(999)))), Positioned.fill(child: Container(decoration: BoxDecoration(color: skin.canvas, borderRadius: BorderRadius.circular(999)))), Padding(padding: const EdgeInsets.fromLTRB(3, 3, 3, 3), child: Container(width: 54, height: 54, alignment: Alignment.center, decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.c2, theme.a, theme.c3], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(999)), child: Text(_f(1, "L"), style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 21.6, fontWeight: FontWeight.w700, height: 1, leadingDistribution: TextLeadingDistribution.even))))]))]));
  }
}
