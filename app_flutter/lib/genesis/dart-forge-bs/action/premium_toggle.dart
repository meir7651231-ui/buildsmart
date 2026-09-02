// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "action" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/action-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// PremiumToggle — seam:fields · מצבים חיים
enum ForgePremiumToggleState { state, state1, state2, state3 }

class ForgePremiumToggle extends StatelessWidget {
  final ForgePremiumToggleState state;
  const ForgePremiumToggle({super.key, this.state = ForgePremiumToggleState.state});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return switch (state) {
      ForgePremiumToggleState.state => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 46, height: 27, alignment: Alignment.center, decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.centerLeft, end: Alignment.centerRight), border: Border.all(color: const Color(0x2EFFFFFF)), borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: theme.gl, offset: const Offset(0, 3), blurRadius: 10, spreadRadius: 0)]), child: Stack(clipBehavior: Clip.none, children: [Positioned.fill(child: const SizedBox.shrink()), Positioned(top: 2, right: 2, child: const SizedBox.shrink())])), Text("on", style: TextStyle(color: skin.ink, fontFamily: fonts.he))]),
      ForgePremiumToggleState.state1 => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 46, height: 27, alignment: Alignment.center, decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.centerLeft, end: Alignment.centerRight), border: Border.all(color: const Color(0x2EFFFFFF)), borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: theme.gl, offset: const Offset(0, 3), blurRadius: 10, spreadRadius: 0)]), child: Stack(clipBehavior: Clip.none, children: [Positioned.fill(child: const SizedBox.shrink()), Positioned(top: 2, right: 2, child: const SizedBox.shrink())])), Text("off", style: TextStyle(color: skin.ink, fontFamily: fonts.he))]),
      ForgePremiumToggleState.state2 => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 46, height: 27, alignment: Alignment.center, decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.centerLeft, end: Alignment.centerRight), border: Border.all(color: const Color(0x2EFFFFFF)), borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: theme.gl, offset: const Offset(0, 3), blurRadius: 10, spreadRadius: 0)]), child: Stack(clipBehavior: Clip.none, children: [Positioned.fill(child: const SizedBox.shrink()), Positioned(top: 2, right: 2, child: const SizedBox.shrink())])), Text("focus", style: TextStyle(color: skin.ink, fontFamily: fonts.he))]),
      ForgePremiumToggleState.state3 => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Opacity(opacity: 0.5, child: Container(width: 46, height: 27, alignment: Alignment.center, decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.centerLeft, end: Alignment.centerRight), border: Border.all(color: const Color(0x2EFFFFFF)), borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: theme.gl, offset: const Offset(0, 3), blurRadius: 10, spreadRadius: 0)]), child: Stack(clipBehavior: Clip.none, children: [Positioned.fill(child: const SizedBox.shrink()), Positioned(top: 2, right: 2, child: const SizedBox.shrink())]))), Text("disabled", style: TextStyle(color: skin.ink, fontFamily: fonts.he))]),
    };
  }
}
