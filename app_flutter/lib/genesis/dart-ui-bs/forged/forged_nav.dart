// 🏭 חושל ע"י pure-forge ממקור-האמת machtzev/pure/nav-family.html — seam-aware, אל תערוך ידנית.
import 'package:flutter/material.dart';
import '../ds/ds_seam.dart';

class ForgedNav extends StatelessWidget {
  const ForgedNav({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);
    final theme = DsSeam.of(context);
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: skin.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: skin.hair)), child: Row(mainAxisSize: MainAxisSize.min, children: [Container(decoration: BoxDecoration(color: theme.aHi, borderRadius: BorderRadius.circular(2)), child: const SizedBox.shrink()), Text('Label'), Text('Label'), Text('Label'), Text('Label')]));
  }
}
