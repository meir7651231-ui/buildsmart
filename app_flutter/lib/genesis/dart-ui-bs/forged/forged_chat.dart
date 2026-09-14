// 🏭 חושל ע"י pure-forge ממקור-האמת machtzev/pure/chat-family.html — seam-aware, אל תערוך ידנית.
import 'package:flutter/material.dart';
import '../ds/ds_seam.dart';

class ForgedChat extends StatelessWidget {
  const ForgedChat({super.key});
  @override
  Widget build(BuildContext context) {
    final fonts = DsSeam.fontsOf(context);
    final skin = DsSeam.skinOf(context);
    return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: skin.surface, border: Border.all(color: skin.hair)), child: Row(mainAxisSize: MainAxisSize.min, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text('Pure', style: TextStyle(fontFamily: fonts.serif, fontSize: 20, fontWeight: FontWeight.w600)), const SizedBox.shrink(), Text('Conversation Appendix')]), Row(mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.all(3), decoration: BoxDecoration(color: skin.sunken, borderRadius: BorderRadius.circular(999), border: Border.all(color: skin.hair)), child: Row(mainAxisSize: MainAxisSize.min, children: [Text('Serif'), Text('Grotesk')])), Container(padding: const EdgeInsets.all(3), decoration: BoxDecoration(color: skin.sunken, borderRadius: BorderRadius.circular(999), border: Border.all(color: skin.hair)), child: Row(mainAxisSize: MainAxisSize.min, children: [Container(decoration: BoxDecoration(color: skin.raised, borderRadius: BorderRadius.circular(999)), child: const SizedBox.shrink()), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text('Indigo'), const SizedBox.shrink()]), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text('Teal'), const SizedBox.shrink()]), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text('Amber'), const SizedBox.shrink()])]))])]));
  }
}
