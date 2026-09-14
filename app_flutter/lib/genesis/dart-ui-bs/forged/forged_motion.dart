// 🏭 חושל ע"י pure-forge ממקור-האמת machtzev/pure/motion-family.html — seam-aware, אל תערוך ידנית.
import 'package:flutter/material.dart';
import '../ds/ds_seam.dart';

class ForgedMotion extends StatelessWidget {
  const ForgedMotion({super.key});
  @override
  Widget build(BuildContext context) {
    final fonts = DsSeam.fontsOf(context);
    final skin = DsSeam.skinOf(context);
    final theme = DsSeam.of(context);
    return Container(decoration: BoxDecoration(color: skin.sunken), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Row(mainAxisSize: MainAxisSize.min, children: [Text('Aurora', style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 8.5)), const SizedBox.shrink()]), Container(decoration: BoxDecoration(color: theme.c2), child: const SizedBox.shrink())]));
  }
}
