// 🏭 חושל ע"י pure-forge ממקור-האמת machtzev/pure/list-family.html — seam-aware, אל תערוך ידנית.
import 'package:flutter/material.dart';
import '../ds/ds_seam.dart';

class ForgedList extends StatelessWidget {
  const ForgedList({super.key});
  @override
  Widget build(BuildContext context) {
    final fonts = DsSeam.fontsOf(context);
    final skin = DsSeam.skinOf(context);
    final theme = DsSeam.of(context);
    return Container(decoration: BoxDecoration(color: skin.surface, borderRadius: BorderRadius.circular(15), border: Border.all(color: skin.hair)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 13), child: Row(mainAxisSize: MainAxisSize.min, children: [Row(mainAxisSize: MainAxisSize.min, children: [Text('Label', style: TextStyle(color: theme.aHi, fontFamily: fonts.he, fontSize: 12.5, fontWeight: FontWeight.w600))]), Text('248', style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 12, fontWeight: FontWeight.w600))])), Container(padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 13), child: Row(mainAxisSize: MainAxisSize.min, children: [Row(mainAxisSize: MainAxisSize.min, children: [Text('Label', style: TextStyle(color: theme.aHi, fontFamily: fonts.he, fontSize: 12.5, fontWeight: FontWeight.w600))]), Text('1,024', style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontSize: 12, fontWeight: FontWeight.w600))])), Container(padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 13), child: Row(mainAxisSize: MainAxisSize.min, children: [Row(mainAxisSize: MainAxisSize.min, children: [Text('Label', style: TextStyle(color: theme.aHi, fontFamily: fonts.he, fontSize: 12.5, fontWeight: FontWeight.w600))]), Text('14', style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 12, fontWeight: FontWeight.w600))]))]));
  }
}
