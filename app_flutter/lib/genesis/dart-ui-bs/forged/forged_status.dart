// 🏭 חושל ע"י pure-forge ממקור-האמת machtzev/pure/status-family.html — seam-aware, אל תערוך ידנית.
import 'package:flutter/material.dart';
import '../ds/ds_seam.dart';

class ForgedStatus extends StatelessWidget {
  const ForgedStatus({super.key});
  @override
  Widget build(BuildContext context) {
    final fonts = DsSeam.fontsOf(context);
    final skin = DsSeam.skinOf(context);
    return Container(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2), child: Row(mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 11), decoration: BoxDecoration(borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.min, children: [Text('Label · info', style: TextStyle(fontFamily: fonts.grotesk, fontSize: 10.5, fontWeight: FontWeight.w700)), const SizedBox.shrink()])), Container(padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 11), decoration: BoxDecoration(borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.min, children: [Text('Label · success', style: TextStyle(fontFamily: fonts.grotesk, fontSize: 10.5, fontWeight: FontWeight.w700)), Icon(Icons.circle_outlined, size: 16, color: skin.mut)])), Container(padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 11), decoration: BoxDecoration(borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.min, children: [Text('Label · warning', style: TextStyle(fontFamily: fonts.grotesk, fontSize: 10.5, fontWeight: FontWeight.w700)), Icon(Icons.circle_outlined, size: 16, color: skin.mut)])), Container(padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 11), decoration: BoxDecoration(borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.min, children: [Text('Label · error', style: TextStyle(fontFamily: fonts.grotesk, fontSize: 10.5, fontWeight: FontWeight.w700)), Icon(Icons.circle_outlined, size: 16, color: skin.mut)])), Container(padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 11), decoration: BoxDecoration(borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.min, children: [Text('Label · neutral', style: TextStyle(fontFamily: fonts.grotesk, fontSize: 10.5, fontWeight: FontWeight.w700)), const SizedBox.shrink()]))]));
  }
}
