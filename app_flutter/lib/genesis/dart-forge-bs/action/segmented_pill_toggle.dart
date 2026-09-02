// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "action" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/action-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// SegmentedPillToggle — seam:fields
class ForgeSegmentedPillToggle extends StatelessWidget {
  const ForgeSegmentedPillToggle({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return SizedBox(width: double.infinity, child: Container(decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Stack(clipBehavior: Clip.none, children: [Padding(padding: const EdgeInsets.fromLTRB(3, 3, 3, 3), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [Expanded(child: Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(8, 8, 8, 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(999)), child: Center(widthFactor: 1.0, heightFactor: 1.0, child: Text("Label", style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 12, fontWeight: FontWeight.w600))))), Expanded(child: Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(8, 8, 8, 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(999)), child: Center(widthFactor: 1.0, heightFactor: 1.0, child: Text("Label", style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 12, fontWeight: FontWeight.w600)))))])), Positioned(top: 3, bottom: 3, left: 0, child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.raised2, skin.raised], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: const Color(0x66000000), offset: const Offset(0, 2), blurRadius: 6, spreadRadius: 0)])))])));
  }
}
