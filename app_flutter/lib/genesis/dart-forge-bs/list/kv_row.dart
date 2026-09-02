// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "list" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/list-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// KvRow — seam:fields
class ForgeKvRow extends StatelessWidget {
  const ForgeKvRow({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(15)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Container(constraints: const BoxConstraints(minHeight: 52), padding: const EdgeInsets.fromLTRB(15, 12, 15, 12), child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 12, children: [Expanded(child: Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 13.5, fontWeight: FontWeight.w600, height: 1.25))), Text("248", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 13, fontWeight: FontWeight.w600))])), Container(constraints: const BoxConstraints(minHeight: 52), padding: const EdgeInsets.fromLTRB(15, 12, 15, 12), child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 12, children: [Expanded(child: Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 13.5, fontWeight: FontWeight.w600, height: 1.25))), Text("+ 12%", style: TextStyle(color: skin.ok, fontFamily: fonts.grotesk, fontSize: 13, fontWeight: FontWeight.w600))])), Container(constraints: const BoxConstraints(minHeight: 52), padding: const EdgeInsets.fromLTRB(15, 12, 15, 12), child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 12, children: [Expanded(child: Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 13.5, fontWeight: FontWeight.w600, height: 1.25))), Text("- 4%", style: TextStyle(color: skin.err, fontFamily: fonts.grotesk, fontSize: 13, fontWeight: FontWeight.w600))])), Container(constraints: const BoxConstraints(minHeight: 52), padding: const EdgeInsets.fromLTRB(15, 12, 15, 12), child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 12, children: [Expanded(child: Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 13.5, fontWeight: FontWeight.w600, height: 1.25))), Text("1,024", style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontSize: 13, fontWeight: FontWeight.w600))]))]));
  }
}
