// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "input" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/input-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// DsField — seam:self · מצבים חיים
enum ForgeDsFieldState { empty, focus, filled, error, disabled }

class ForgeDsField extends StatelessWidget {
  final ForgeDsFieldState state;
  const ForgeDsField({super.key, this.state = ForgeDsFieldState.empty});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return switch (state) {
      ForgeDsFieldState.empty => Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 6, children: [Text("Label", style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 11, fontWeight: FontWeight.w600)), Text("Value", style: TextStyle(color: skin.faint, fontFamily: fonts.he, fontSize: 13))]),
      ForgeDsFieldState.focus => Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 6, children: [Text("Label", style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 11, fontWeight: FontWeight.w600)), Text("Value", style: TextStyle(color: skin.faint, fontFamily: fonts.he, fontSize: 13))]),
      ForgeDsFieldState.filled => Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 6, children: [Text("Label", style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 11, fontWeight: FontWeight.w600)), Text("Value", style: TextStyle(color: skin.faint, fontFamily: fonts.he, fontSize: 13))]),
      ForgeDsFieldState.error => Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 6, children: [Text("Label", style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 11, fontWeight: FontWeight.w600)), Text("Value", style: TextStyle(color: skin.faint, fontFamily: fonts.he, fontSize: 13)), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Container(decoration: BoxDecoration(color: skin.err, borderRadius: BorderRadius.circular(50))), Text("Meta · error", style: TextStyle(color: skin.ink, fontFamily: fonts.he))])]),
      ForgeDsFieldState.disabled => Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 6, children: [Text("Label", style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 11, fontWeight: FontWeight.w600)), Text("Value", style: TextStyle(color: skin.faint, fontFamily: fonts.he, fontSize: 13))]),
    };
  }
}
