// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "action" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/action-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// PrimaryBtn — seam:fields · מצבים חיים
enum ForgePrimaryBtnState { state, state1, state2, state3, state4, state5 }

class ForgePrimaryBtn extends StatelessWidget {
  final ForgePrimaryBtnState state;
  const ForgePrimaryBtn({super.key, this.state = ForgePrimaryBtnState.state});
  @override
  Widget build(BuildContext context) {
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return switch (state) {
      ForgePrimaryBtnState.state => Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Action", style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w700)), Text("default")]),
      ForgePrimaryBtnState.state1 => Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Action", style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w700)), Text("hover")]),
      ForgePrimaryBtnState.state2 => Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Action", style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w700)), Text("focus")]),
      ForgePrimaryBtnState.state3 => Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Action", style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w700)), Text("selected")]),
      ForgePrimaryBtnState.state4 => Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Action", style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w700)), Text("disabled")]),
      ForgePrimaryBtnState.state5 => Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16), decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a, theme.a800], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(11)), child: Row(mainAxisSize: MainAxisSize.min, spacing: 7, children: [Container(decoration: BoxDecoration(border: Border.all(color: const Color(0x660B0B0D), width: 2), borderRadius: BorderRadius.circular(50)))])), Text("loading")]),
    };
  }
}
