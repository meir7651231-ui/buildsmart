// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "action" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/action-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// PrimaryBtn — seam:fields
class ForgePrimaryBtn extends StatelessWidget {
  const ForgePrimaryBtn({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(0, 4, 0, 2), child: Row(mainAxisSize: MainAxisSize.min, spacing: 18, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 8, children: [Text("Action", style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w700)), Text("default")]), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 8, children: [Text("Action", style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w700)), Text("hover")]), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 8, children: [Text("Action", style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w700)), Text("focus")]), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 8, children: [Text("Action", style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w700)), Text("selected")]), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 8, children: [Text("Action", style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w700)), Text("disabled")]), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 8, children: [Container(padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16), decoration: BoxDecoration(color: theme.aHi, borderRadius: BorderRadius.circular(11)), child: Row(mainAxisSize: MainAxisSize.min, spacing: 7, children: [Container(decoration: BoxDecoration(border: Border.all(color: const Color(0x660B0B0D), width: 2), borderRadius: BorderRadius.circular(50)))])), Text("loading")])]));
  }
}
