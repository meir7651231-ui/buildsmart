// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "header" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/header-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// DsDateField — seam:divider
class ForgeDsDateField extends StatelessWidget {
  const ForgeDsDateField({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(16, 12, 16, 12), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Container(padding: const EdgeInsets.fromLTRB(2, 6, 2, 6), child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 12, children: [Flexible(child: Directionality(textDirection: TextDirection.ltr, child: Text("LABEL", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2), overflow: TextOverflow.ellipsis, softWrap: false))), Expanded(child: Container(height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.hair, const Color(0x00000000)], begin: Alignment.centerLeft, end: Alignment.centerRight)))), Flexible(child: Directionality(textDirection: TextDirection.ltr, child: Text("Today", style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis, softWrap: false)))])));
  }
}
