// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "media" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/media-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// CoverBanner — seam:fields · 2 חריצים
class ForgeCoverBanner extends StatelessWidget {
  /// תפר-דאטה (G12a): 2 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 2;
  static const List<String> fieldDemo = <String>["Label", "Meta"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  const ForgeCoverBanner({super.key, this.fields});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(constraints: const BoxConstraints(minHeight: 132), decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.a800, theme.a, theme.c3], begin: Alignment.topLeft, end: Alignment.bottomRight), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), foregroundDecoration: BoxDecoration(gradient: RadialGradient(center: Alignment(0.64, -1.50), radius: 1.30, colors: [theme.gl, const Color(0x00000000)], stops: [0.0, 0.55]), borderRadius: BorderRadius.circular(16)), child: SizedBox(width: double.infinity, child: Stack(clipBehavior: Clip.none, alignment: Alignment.bottomRight, children: [Positioned.fill(child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [const Color(0x66000000), const Color(0x00000000)], begin: Alignment.bottomCenter, end: Alignment.topCenter)))), Padding(padding: const EdgeInsets.fromLTRB(18, 18, 18, 18), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, spacing: 2, children: [Text(_f(0, "Label"), style: TextStyle(color: const Color(0xFFFFFFFF), fontFamily: fonts.serifHe, fontSize: 18, fontWeight: FontWeight.w700)), SizedBox(width: double.infinity, child: Directionality(textDirection: TextDirection.ltr, child: Text(_f(1, "Meta"), style: TextStyle(color: const Color(0xD9FFFFFF), fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11))))]))])));
  }
}
