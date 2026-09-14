// 🏭 חושל ע"י pure-forge ממקור-האמת machtzev/pure/header-family.html — seam-aware, אל תערוך ידנית.
import 'package:flutter/material.dart';
import '../ds/ds_seam.dart';

class ForgedHeader extends StatelessWidget {
  const ForgedHeader({super.key});
  @override
  Widget build(BuildContext context) {
    final fonts = DsSeam.fontsOf(context);
    final skin = DsSeam.skinOf(context);
    final theme = DsSeam.of(context);
    return Container(padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18), decoration: BoxDecoration(color: skin.surface), child: Row(mainAxisSize: MainAxisSize.min, children: [Container(decoration: BoxDecoration(color: theme.gl, borderRadius: BorderRadius.circular(9), border: Border.all(color: skin.hair)), child: Icon(Icons.circle_outlined, size: 16, color: skin.mut)), Text('Label', style: TextStyle(color: skin.ink, fontSize: 17, fontWeight: FontWeight.w700)), Text('12', style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontSize: 10, fontWeight: FontWeight.w700)), Row(mainAxisSize: MainAxisSize.min, children: [Text('Action', style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontSize: 11, fontWeight: FontWeight.w600)), Icon(Icons.circle_outlined, size: 16, color: skin.mut)])]));
  }
}
