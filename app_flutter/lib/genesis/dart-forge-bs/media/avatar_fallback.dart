// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "media" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/media-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// AvatarFallback — seam:fields · 2 חריצים
class ForgeAvatarFallback extends StatelessWidget {
  /// תפר-דאטה (G12a): 2 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 2;
  static const List<String> fieldDemo = <String>["L", "no avatar"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  const ForgeAvatarFallback({super.key, this.fields});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(constraints: const BoxConstraints(minHeight: 120), padding: const EdgeInsets.fromLTRB(22, 22, 22, 22), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair, width: 1.5), borderRadius: BorderRadius.circular(12)), child: Center(widthFactor: 1.0, heightFactor: 1.0, child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 8, children: [Container(width: 44, height: 44, alignment: Alignment.center, decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.raised2, skin.surface], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(999)), child: Text(_f(0, "L"), style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 17.6, fontWeight: FontWeight.w700, height: 1, leadingDistribution: TextLeadingDistribution.even))), Directionality(textDirection: TextDirection.ltr, child: Text(_f(1, "no avatar"), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 10)))])));
  }
}
