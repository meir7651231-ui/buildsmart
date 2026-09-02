// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "chat" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/chat-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// QuickReply — seam:fields
class ForgeQuickReply extends StatelessWidget {
  const ForgeQuickReply({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 8, children: [Container(constraints: const BoxConstraints(minHeight: 38), padding: const EdgeInsets.fromLTRB(14, 8, 14, 8), decoration: BoxDecoration(color: theme.a, border: Border.all(color: theme.a800), borderRadius: BorderRadius.circular(999)), child: Text("Label", style: TextStyle(color: theme.aHi, fontFamily: fonts.he, fontSize: 12.5))), Container(constraints: const BoxConstraints(minHeight: 38), padding: const EdgeInsets.fromLTRB(14, 8, 14, 8), decoration: BoxDecoration(color: theme.a, border: Border.all(color: theme.a800), borderRadius: BorderRadius.circular(999)), child: Text("Label", style: TextStyle(color: theme.aHi, fontFamily: fonts.he, fontSize: 12.5))), Container(constraints: const BoxConstraints(minHeight: 38), padding: const EdgeInsets.fromLTRB(14, 8, 14, 8), decoration: BoxDecoration(color: theme.a, border: Border.all(color: theme.a800), borderRadius: BorderRadius.circular(999)), child: Text("Value", style: TextStyle(color: theme.aHi, fontFamily: fonts.he, fontSize: 12.5))), Container(constraints: const BoxConstraints(minHeight: 38), padding: const EdgeInsets.fromLTRB(14, 8, 14, 8), decoration: BoxDecoration(color: theme.a, border: Border.all(color: theme.a800), borderRadius: BorderRadius.circular(999)), child: Text("Label", style: TextStyle(color: theme.aHi, fontFamily: fonts.he, fontSize: 12.5)))]));
  }
}
