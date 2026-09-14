// 🏭 חושל ע"י pure-forge ממקור-האמת machtzev/pure/composite-family.html — seam-aware, אל תערוך ידנית.
import 'package:flutter/material.dart';
import '../ds/ds_seam.dart';

class ForgedComposite extends StatelessWidget {
  const ForgedComposite({super.key});
  @override
  Widget build(BuildContext context) {
    final fonts = DsSeam.fontsOf(context);
    final theme = DsSeam.of(context);
    return Container(padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14), decoration: BoxDecoration(color: theme.gl), child: Row(mainAxisSize: MainAxisSize.min, children: [Text('L', style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.grotesk, fontSize: 12, fontWeight: FontWeight.w700)), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text('Label'), Text('Meta')])]));
  }
}
