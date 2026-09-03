// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "input" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/input-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// WheelPicker — seam:self
class ForgeWheelPicker extends StatelessWidget {
  const ForgeWheelPicker({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    return Container(padding: const EdgeInsets.fromLTRB(0, 2, 0, 2), child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 14, children: [Container(width: 132, height: 264, decoration: BoxDecoration(gradient: RadialGradient(center: Alignment(0.00, 0.00), radius: 1.20, colors: [skin.surface, skin.sunken], stops: [0.0, 1.0]), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Stack(clipBehavior: Clip.none, children: [Positioned.fill(child: const SizedBox.shrink()), Positioned(left: 0, right: 0, child: Opacity(opacity: 0.6, child: Container(height: 48, padding: const EdgeInsets.fromLTRB(0, 22, 0, 22), decoration: BoxDecoration(color: theme.a.withValues(alpha: 0.080), border: Border(top: BorderSide(color: theme.a, width: 1), bottom: BorderSide(color: theme.a, width: 1))))))])), Container(width: 132, height: 264, decoration: BoxDecoration(gradient: RadialGradient(center: Alignment(0.00, 0.00), radius: 1.20, colors: [skin.surface, skin.sunken], stops: [0.0, 1.0]), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Stack(clipBehavior: Clip.none, children: [Positioned.fill(child: const SizedBox.shrink()), Positioned(left: 0, right: 0, child: Opacity(opacity: 0.6, child: Container(height: 48, padding: const EdgeInsets.fromLTRB(0, 22, 0, 22), decoration: BoxDecoration(color: theme.a.withValues(alpha: 0.080), border: Border(top: BorderSide(color: theme.a, width: 1), bottom: BorderSide(color: theme.a, width: 1))))))]))]));
  }
}
