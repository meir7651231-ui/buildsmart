// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "action" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/action-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// PillCtaButton — seam:fields
class ForgePillCtaButton extends StatelessWidget {
  const ForgePillCtaButton({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(height: 44, alignment: Alignment.center, padding: const EdgeInsets.fromLTRB(16, 0, 16, 0), decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a, theme.a800], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: const Color(0x66000000), offset: const Offset(0, 1), blurRadius: 2, spreadRadius: 0), BoxShadow(color: theme.gl, offset: const Offset(0, 7), blurRadius: 18, spreadRadius: 0)]), child: Text("Action", style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w700)));
  }
}
