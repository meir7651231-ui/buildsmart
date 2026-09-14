// 🏭 חושל ע"י pure-forge ממקור-האמת machtzev/pure/feedback-family.html — seam-aware, אל תערוך ידנית.
import 'package:flutter/material.dart';
import '../ds/ds_seam.dart';

class ForgedFeedback extends StatelessWidget {
  const ForgedFeedback({super.key});
  @override
  Widget build(BuildContext context) {
    final fonts = DsSeam.fontsOf(context);
    final skin = DsSeam.skinOf(context);
    return Row(mainAxisSize: MainAxisSize.min, children: [Text('Action', style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.he, fontSize: 12.5, fontWeight: FontWeight.w700)), Text('Action', style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 12.5, fontWeight: FontWeight.w700))]);
  }
}
