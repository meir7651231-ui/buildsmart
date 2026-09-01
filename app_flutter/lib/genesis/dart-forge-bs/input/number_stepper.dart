// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "input" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/input-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
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
    return switch (state) {
      ForgeNumberStepperState.defaultLive => Container(decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: Row(mainAxisSize: MainAxisSize.min, children: [Text("−"), Text("2"), Text("+")])),
      ForgeNumberStepperState.focus => Container(decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: Row(mainAxisSize: MainAxisSize.min, children: [Text("−"), Text("3"), Text("+")])),
      ForgeNumberStepperState.minDisabled => Container(decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: Row(mainAxisSize: MainAxisSize.min, children: [Text("−"), Text("0"), Text("+")])),
    };
  }
}
