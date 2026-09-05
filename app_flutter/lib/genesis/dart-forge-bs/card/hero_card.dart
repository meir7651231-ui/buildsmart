// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "card" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/card-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// HeroCard — seam:fields · 3 חריצים
class ForgeHeroCard extends StatelessWidget {
  /// תפר-דאטה (G12a): 3 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 3;
  static const List<String> fieldDemo = <String>["HERO", "Label", "Meta"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  const ForgeHeroCard({super.key, this.fields});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(constraints: const BoxConstraints(minHeight: 130), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.raised, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), foregroundDecoration: BoxDecoration(gradient: RadialGradient(center: Alignment(0.60, -1.20), radius: 1.20, colors: [theme.gl, const Color(0x00000000)], stops: [0.0, 0.55]), borderRadius: BorderRadius.circular(16)), child: SizedBox(width: double.infinity, child: Stack(clipBehavior: Clip.none, children: [Padding(padding: const EdgeInsets.fromLTRB(18, 18, 18, 18), child: Padding(padding: const EdgeInsets.only(top: 16, bottom: 0), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_f(1, "Label"), style: TextStyle(color: skin.ink, fontFamily: fonts.serifHe, fontSize: 18, fontWeight: FontWeight.w600)), const SizedBox(height: 3), Text(_f(2, "Meta"), style: TextStyle(color: skin.mut, fontSize: 11.5, fontFamily: fonts.he))]))), Positioned(top: 14, left: 14, child: Directionality(textDirection: TextDirection.ltr, child: Text(_f(0, "HERO"), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 8, letterSpacing: 1))))])));
  }
}
