// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "action" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/action-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// PremiumToggle — seam:fields · מצבים חיים
enum ForgePremiumToggleState { state, state1, state2, state3 }

class ForgePremiumToggle extends StatelessWidget {
  final ForgePremiumToggleState state;
  const ForgePremiumToggle({super.key, this.state = ForgePremiumToggleState.state});
  @override
  Widget build(BuildContext context) {
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    return switch (state) {
      ForgePremiumToggleState.state => Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.all(3), decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.centerLeft, end: Alignment.centerRight), border: Border.all(color: const Color(0x2EFFFFFF)), borderRadius: BorderRadius.circular(999)), child: const SizedBox.shrink()), Text("on")]),
      ForgePremiumToggleState.state1 => Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.all(3), decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.centerLeft, end: Alignment.centerRight), border: Border.all(color: const Color(0x2EFFFFFF)), borderRadius: BorderRadius.circular(999)), child: const SizedBox.shrink()), Text("off")]),
      ForgePremiumToggleState.state2 => Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.all(3), decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.centerLeft, end: Alignment.centerRight), border: Border.all(color: const Color(0x2EFFFFFF)), borderRadius: BorderRadius.circular(999)), child: const SizedBox.shrink()), Text("focus")]),
      ForgePremiumToggleState.state3 => Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.all(3), decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.centerLeft, end: Alignment.centerRight), border: Border.all(color: const Color(0x2EFFFFFF)), borderRadius: BorderRadius.circular(999)), child: const SizedBox.shrink()), Text("disabled")]),
    };
  }
}
