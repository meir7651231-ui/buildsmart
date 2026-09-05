// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "action" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/action-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// GlassButton — seam:fields · 1 חריצים
class ForgeGlassButton extends StatelessWidget {
  /// תפר-דאטה (G12a): 1 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 1;
  static const List<String> fieldDemo = <String>["Action"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  const ForgeGlassButton({super.key, this.fields});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return ClipRRect(borderRadius: BorderRadius.circular(11), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: Container(height: 44, decoration: BoxDecoration(color: const Color(0x12FFFFFF), border: Border.all(color: const Color(0x29FFFFFF)), borderRadius: BorderRadius.circular(11), boxShadow: [BoxShadow(color: const Color(0x66000000), offset: const Offset(0, 8), blurRadius: 24, spreadRadius: 0)]), child: Center(widthFactor: 1.0, child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 0), child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, spacing: 7, children: [Text(_f(0, "Action"), style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w700))])), Positioned(top: 0, left: 0, right: 0, child: Container(height: 1.2, decoration: BoxDecoration(gradient: LinearGradient(colors: [const Color(0x00000000), const Color(0xB3FFFFFF), const Color(0x00000000)], begin: Alignment.centerLeft, end: Alignment.centerRight))))])))));
  }
}
