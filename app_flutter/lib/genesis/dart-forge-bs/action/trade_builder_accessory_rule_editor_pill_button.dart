// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "action" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/action-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// TradeBuilderAccessoryRuleEditorPillButton — seam:fields
class ForgeTradeBuilderAccessoryRuleEditorPillButton extends StatelessWidget {
  const ForgeTradeBuilderAccessoryRuleEditorPillButton({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return SizedBox(width: double.infinity, child: Container(height: 44, decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a, theme.a800], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: const Color(0x66000000), offset: const Offset(0, 1), blurRadius: 2, spreadRadius: 0), BoxShadow(color: theme.gl, offset: const Offset(0, 7), blurRadius: 18, spreadRadius: 0)]), child: Center(widthFactor: 1.0, child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 0), child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, spacing: 7, children: [Text("Action", style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w700))])), Positioned(top: 0, left: 0, right: 0, child: Container(height: 1.2, decoration: BoxDecoration(color: const Color(0xB3FFFFFF))))]))));
  }
}
