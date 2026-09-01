// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "action" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/action-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// PillCtaButton — seam:fields
class ForgePillCtaButton extends StatelessWidget {
  const ForgePillCtaButton({super.key});
  @override
  Widget build(BuildContext context) {
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Text("Action", style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w700));
  }
}
