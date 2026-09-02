// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "input" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/input-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// GlowField — seam:fields
class ForgeGlowField extends StatelessWidget {
  const ForgeGlowField({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 6, children: [Text("Label", textAlign: TextAlign.right, style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 11, fontWeight: FontWeight.w600)), Container(height: 44, constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(13, 0, 13, 0), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11), boxShadow: [BoxShadow(color: theme.gl, offset: const Offset(0, 0), blurRadius: 0, spreadRadius: 3), BoxShadow(color: theme.gl, offset: const Offset(0, 0), blurRadius: 34, spreadRadius: 0), BoxShadow(color: theme.gl, offset: const Offset(0, 0), blurRadius: 66, spreadRadius: 0)]), child: Text("Value", style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 13)))]);
  }
}
