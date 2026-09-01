// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "action" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/action-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// GlassButton — seam:fields
class ForgeGlassButton extends StatelessWidget {
  const ForgeGlassButton({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(height: 44, padding: const EdgeInsets.fromLTRB(16, 0, 16, 0), decoration: BoxDecoration(color: const Color(0x12FFFFFF), border: Border.all(color: const Color(0x29FFFFFF)), borderRadius: BorderRadius.circular(11), boxShadow: [BoxShadow(color: const Color(0x66000000), offset: const Offset(0, 8), blurRadius: 24, spreadRadius: 0)]), child: Text("Action", style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w700)));
  }
}
