// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "card" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/card-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// StatusDot — seam:fields
class ForgeStatusDot extends StatelessWidget {
  const ForgeStatusDot({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(2, 10, 2, 10), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 14, children: [Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 8, children: [Container(width: 9, height: 9, decoration: BoxDecoration(color: skin.ok, borderRadius: BorderRadius.circular(50), boxShadow: [BoxShadow(color: skin.ok, offset: const Offset(0, 0), blurRadius: 0, spreadRadius: 3)])), Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.he))]), Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 8, children: [Container(width: 9, height: 9, decoration: BoxDecoration(color: skin.faint, borderRadius: BorderRadius.circular(50))), Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.he))]), Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 8, children: [Container(width: 9, height: 9, decoration: BoxDecoration(color: skin.warn, borderRadius: BorderRadius.circular(50))), Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.he))])]));
  }
}
