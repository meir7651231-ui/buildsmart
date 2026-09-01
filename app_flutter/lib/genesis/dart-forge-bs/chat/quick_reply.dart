// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "chat" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/chat-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// QuickReply — seam:fields
class ForgeQuickReply extends StatelessWidget {
  const ForgeQuickReply({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.all(16), child: Row(mainAxisSize: MainAxisSize.min, spacing: 8, children: [Text("Label", style: TextStyle(color: theme.aHi, fontFamily: fonts.he, fontSize: 12.5)), Text("Label", style: TextStyle(color: theme.aHi, fontFamily: fonts.he, fontSize: 12.5)), Text("Value", style: TextStyle(color: theme.aHi, fontFamily: fonts.he, fontSize: 12.5)), Text("Label", style: TextStyle(color: theme.aHi, fontFamily: fonts.he, fontSize: 12.5))]));
  }
}
