// 🏭 חושל ע"י pure-forge ממקור-האמת machtzev/pure/spatial-family.html — seam-aware, אל תערוך ידנית.
import 'package:flutter/material.dart';
import '../ds/ds_seam.dart';

class ForgedSpatial extends StatelessWidget {
  const ForgedSpatial({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);
    return Icon(Icons.circle_outlined, size: 16, color: skin.mut);
  }
}
