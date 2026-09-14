// 🏭 חושל ע"י pure-forge ממקור-האמת machtzev/pure/temporal-family.html — seam-aware, אל תערוך ידנית.
import 'package:flutter/material.dart';
import '../ds/ds_seam.dart';

class ForgedTemporal extends StatelessWidget {
  const ForgedTemporal({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);
    return Container(decoration: BoxDecoration(color: skin.sunken), child: const SizedBox.shrink());
  }
}
