// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "input" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/input-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// WheelPicker — seam:self
class ForgeWheelPicker extends StatelessWidget {
  const ForgeWheelPicker({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    return Container(padding: const EdgeInsets.fromLTRB(0, 2, 0, 2), child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 14, children: [Container(width: 132, height: 264, decoration: BoxDecoration(color: skin.surface, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Stack(clipBehavior: Clip.none, children: [Positioned.fill(child: const SizedBox.shrink()), Positioned.fill(child: Opacity(opacity: 0.6, child: Container(height: 48, padding: const EdgeInsets.fromLTRB(0, 22, 0, 22), decoration: BoxDecoration(color: theme.a))))])), Container(width: 132, height: 264, decoration: BoxDecoration(color: skin.surface, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Stack(clipBehavior: Clip.none, children: [Positioned.fill(child: const SizedBox.shrink()), Positioned.fill(child: Opacity(opacity: 0.6, child: Container(height: 48, padding: const EdgeInsets.fromLTRB(0, 22, 0, 22), decoration: BoxDecoration(color: theme.a))))]))]));
  }
}
