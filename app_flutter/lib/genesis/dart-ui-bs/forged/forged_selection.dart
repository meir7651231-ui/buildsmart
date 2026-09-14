// 🏭 חושל ע"י pure-forge ממקור-האמת machtzev/pure/selection-family.html — seam-aware, אל תערוך ידנית.
import 'package:flutter/material.dart';
import '../ds/ds_seam.dart';

class ForgedSelection extends StatelessWidget {
  const ForgedSelection({super.key});
  @override
  Widget build(BuildContext context) {
    final fonts = DsSeam.fontsOf(context);
    final skin = DsSeam.skinOf(context);
    final theme = DsSeam.of(context);
    return Container(decoration: BoxDecoration(color: theme.aHi), child: Row(mainAxisSize: MainAxisSize.min, children: [Container(decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.ink)), child: const SizedBox.shrink()), Row(mainAxisSize: MainAxisSize.min, children: [Text('Label', style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w500)), Text('Meta', style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 10))])]));
  }
}
