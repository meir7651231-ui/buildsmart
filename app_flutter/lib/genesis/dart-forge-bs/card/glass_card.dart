// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "card" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/card-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// GlassCard — seam:fields · 3 חריצים
class ForgeGlassCard extends StatelessWidget {
  /// תפר-דאטה (G12a): 3 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 3;
  static const List<String> fieldDemo = <String>["GLASS", "Label", "Meta"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  const ForgeGlassCard({super.key, this.fields});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return ClipRRect(borderRadius: BorderRadius.circular(16), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), child: Container(constraints: const BoxConstraints(minHeight: 130), decoration: BoxDecoration(color: const Color(0x0FFFFFFF), border: Border.all(color: const Color(0x29FFFFFF)), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0x66000000), offset: const Offset(0, 12), blurRadius: 34, spreadRadius: 0)]), child: SizedBox(width: double.infinity, child: Stack(clipBehavior: Clip.none, children: [Padding(padding: const EdgeInsets.fromLTRB(18, 18, 18, 18), child: Padding(padding: const EdgeInsets.only(top: 16, bottom: 0), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_f(1, "Label"), style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 14, fontWeight: FontWeight.w600)), const SizedBox(height: 3), Text(_f(2, "Meta"), style: TextStyle(color: skin.mut, fontSize: 11.5, fontFamily: fonts.he))]))), Positioned(top: 14, left: 14, child: Directionality(textDirection: TextDirection.ltr, child: Text(_f(0, "GLASS"), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 8, letterSpacing: 1))))])))));
  }
}
