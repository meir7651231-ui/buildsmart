// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "action" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/action-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';

/// CircleFab — seam:fields
class ForgeCircleFab extends StatelessWidget {
  const ForgeCircleFab({super.key});
  @override
  Widget build(BuildContext context) {
    return Text("＋", style: TextStyle(color: const Color(0xFF0B0B0D), fontSize: 23));
  }
}
