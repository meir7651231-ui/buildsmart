// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "action" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/action-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// CourierFormsPillButton — seam:fields
class ForgeCourierFormsPillButton extends StatelessWidget {
  const ForgeCourierFormsPillButton({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(height: 44, decoration: BoxDecoration(border: Border.all(color: theme.a, width: 1.5), borderRadius: BorderRadius.circular(999)), child: Center(widthFactor: 1.0, child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 0), child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, spacing: 7, children: [Text("Action", style: TextStyle(color: theme.aHi, fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w700))])), Positioned(top: 0, left: 0, right: 0, child: Container(height: 1.2, decoration: BoxDecoration(gradient: LinearGradient(colors: [const Color(0x00000000), const Color(0xB3FFFFFF), const Color(0x00000000)], begin: Alignment.centerLeft, end: Alignment.centerRight))))])));
  }
}
