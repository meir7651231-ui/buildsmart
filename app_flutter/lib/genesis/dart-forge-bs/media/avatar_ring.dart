// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "media" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/media-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// AvatarRing — seam:fields · 2 חריצים
class ForgeAvatarRing extends StatelessWidget {
  /// תפר-דאטה (G12a): 2 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 2;
  static const List<String> fieldDemo = <String>["L", "L"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  const ForgeAvatarRing({super.key, this.fields});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(height: 88, alignment: Alignment.centerRight, child: Wrap(spacing: 14, runSpacing: 14, crossAxisAlignment: WrapCrossAlignment.center, children: [Container(width: 44, height: 44, alignment: Alignment.center, decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: skin.canvas, offset: const Offset(0, 0), blurRadius: 0, spreadRadius: 2), BoxShadow(color: theme.a, offset: const Offset(0, 0), blurRadius: 0, spreadRadius: 4)]), child: Text(_f(0, "L"), style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 17.6, fontWeight: FontWeight.w700, height: 1, leadingDistribution: TextLeadingDistribution.even))), Stack(clipBehavior: Clip.none, children: [Container(width: 44, height: 44, alignment: Alignment.center, decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: skin.canvas, offset: const Offset(0, 0), blurRadius: 0, spreadRadius: 2), BoxShadow(color: theme.a, offset: const Offset(0, 0), blurRadius: 0, spreadRadius: 4)]), child: Text(_f(1, "L"), style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 17.6, fontWeight: FontWeight.w700, height: 1, leadingDistribution: TextLeadingDistribution.even))), Positioned(bottom: -2, left: -2, width: 14, child: Container(width: 14, height: 14, decoration: BoxDecoration(color: skin.ok, border: Border.all(color: skin.canvas, width: 2.5), borderRadius: BorderRadius.circular(999))))])]));
  }
}
