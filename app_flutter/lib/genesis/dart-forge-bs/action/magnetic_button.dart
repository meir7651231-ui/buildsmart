// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "action" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/action-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// MagneticButton — seam:fields
class ForgeMagneticButton extends StatelessWidget {
  const ForgeMagneticButton({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(height: 44, padding: const EdgeInsets.fromLTRB(16, 0, 16, 0), decoration: BoxDecoration(border: Border.all(color: theme.a), borderRadius: BorderRadius.circular(11)), child: Center(widthFactor: 1.0, child: Text("Action", style: TextStyle(color: theme.aHi, fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w700))));
  }
}
