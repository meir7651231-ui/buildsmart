// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "feedback" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/feedback-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// ModalDialog — seam:fields
class ForgeModalDialog extends StatelessWidget {
  const ForgeModalDialog({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(14)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("modal · over scrim", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 8)), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [const SizedBox.shrink(), const SizedBox.shrink(), const SizedBox.shrink(), const SizedBox.shrink()]), Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0x94060608)), child: Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: skin.raised, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 12, children: [Text("Label"), Text("Meta"), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Action", style: TextStyle(fontFamily: fonts.he, fontSize: 12.5, fontWeight: FontWeight.w700)), Text("Action", style: TextStyle(fontFamily: fonts.he, fontSize: 12.5, fontWeight: FontWeight.w700))])])))]));
  }
}
