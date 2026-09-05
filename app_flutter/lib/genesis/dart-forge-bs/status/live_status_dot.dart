// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "status" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/status-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// LiveStatusDot — seam:fields
class ForgeLiveStatusDot extends StatelessWidget {
  const ForgeLiveStatusDot({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(2, 8, 2, 8), child: Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 8, children: [Container(width: 9, height: 9, decoration: BoxDecoration(color: skin.ok, borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: skin.ok, offset: const Offset(0, 0), blurRadius: 0, spreadRadius: 3)])), Text("Label", style: TextStyle(color: skin.mut, fontSize: 12, fontFamily: fonts.he))])]));
  }
}
