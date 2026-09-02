// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "action" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/action-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// CircleFab — seam:fields
class ForgeCircleFab extends StatelessWidget {
  const ForgeCircleFab({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(width: 52, height: 52, decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(50), boxShadow: [BoxShadow(color: theme.gl, offset: const Offset(0, 12), blurRadius: 26, spreadRadius: 0)]), child: Text("＋", style: TextStyle(color: const Color(0xFF0B0B0D), fontSize: 23, fontFamily: fonts.he)));
  }
}
