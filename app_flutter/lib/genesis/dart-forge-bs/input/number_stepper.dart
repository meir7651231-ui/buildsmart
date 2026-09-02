// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "input" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/input-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// NumberStepper — seam:fields · מצבים חיים
enum ForgeNumberStepperState { defaultLive, focus, minDisabled }

class ForgeNumberStepper extends StatelessWidget {
  final ForgeNumberStepperState state;
  const ForgeNumberStepper({super.key, this.state = ForgeNumberStepperState.defaultLive});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return switch (state) {
      ForgeNumberStepperState.defaultLive => Container(decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [Text("−", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Container(constraints: const BoxConstraints(minWidth: 46), child: Text("2", textAlign: TextAlign.center, style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontWeight: FontWeight.w600))), Text("+", style: TextStyle(color: skin.ink, fontFamily: fonts.he))])),
      ForgeNumberStepperState.focus => Container(decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11), boxShadow: [BoxShadow(color: theme.gl, offset: const Offset(0, 0), blurRadius: 0, spreadRadius: 3)]), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [Text("−", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Container(constraints: const BoxConstraints(minWidth: 46), child: Text("3", textAlign: TextAlign.center, style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontWeight: FontWeight.w600))), Text("+", style: TextStyle(color: skin.ink, fontFamily: fonts.he))])),
      ForgeNumberStepperState.minDisabled => Container(decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [Opacity(opacity: 0.35, child: Text("−", style: TextStyle(color: skin.ink, fontFamily: fonts.he))), Container(constraints: const BoxConstraints(minWidth: 46), child: Text("0", textAlign: TextAlign.center, style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontWeight: FontWeight.w600))), Text("+", style: TextStyle(color: skin.ink, fontFamily: fonts.he))])),
    };
  }
}
