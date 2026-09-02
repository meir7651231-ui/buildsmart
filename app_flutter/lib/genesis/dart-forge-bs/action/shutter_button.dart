// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "action" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/action-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// ShutterButton — seam:fields
class ForgeShutterButton extends StatelessWidget {
  const ForgeShutterButton({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    return Container(width: 52, height: 52, alignment: Alignment.center, decoration: BoxDecoration(border: Border.all(color: theme.aHi), borderRadius: BorderRadius.circular(50)));
  }
}
