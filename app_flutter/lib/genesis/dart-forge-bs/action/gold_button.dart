// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "action" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/action-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// GoldButton — seam:fields
class ForgeGoldButton extends StatelessWidget {
  const ForgeGoldButton({super.key});
  @override
  Widget build(BuildContext context) {
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(height: 44, padding: const EdgeInsets.fromLTRB(16, 0, 16, 0), decoration: BoxDecoration(gradient: LinearGradient(colors: [const Color(0xFFFBEFC0), const Color(0xFFE6C766), const Color(0xFFB98F2E)], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: const Color(0x80FFF0BE)), borderRadius: BorderRadius.circular(11), boxShadow: [BoxShadow(color: const Color(0x73C89628), offset: const Offset(0, 8), blurRadius: 22, spreadRadius: 0)]), child: Center(widthFactor: 1.0, child: Text("Action", style: TextStyle(color: const Color(0xFF3A2C05), fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w700))));
  }
}
