// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "card" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/card-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// DsRecordCard — seam:fields
class ForgeDsRecordCard extends StatelessWidget {
  const ForgeDsRecordCard({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(15)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.fromLTRB(15, 14, 15, 14), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 11, children: [Container(width: 40, height: 40, decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(11)), child: Text("L", style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.grotesk, fontWeight: FontWeight.w700))), Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Text("Meta", style: TextStyle(color: skin.ink, fontFamily: fonts.he))]), Container(padding: const EdgeInsets.fromLTRB(7, 2, 7, 2), decoration: BoxDecoration(color: skin.ok, border: Border.all(color: skin.ok), borderRadius: BorderRadius.circular(999)), child: Text("LIVE", style: TextStyle(color: skin.ok, fontFamily: fonts.grotesk, fontSize: 9, fontWeight: FontWeight.w700)))])), Container(padding: const EdgeInsets.fromLTRB(15, 6, 15, 12), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.fromLTRB(0, 7, 0, 7), child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [Text("Label", style: TextStyle(color: skin.mut, fontFamily: fonts.he)), Text("248", style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk))])), Container(padding: const EdgeInsets.fromLTRB(0, 7, 0, 7), child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [Text("Label", style: TextStyle(color: skin.mut, fontFamily: fonts.he)), Text("1,024", style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk))]))]))]));
  }
}
