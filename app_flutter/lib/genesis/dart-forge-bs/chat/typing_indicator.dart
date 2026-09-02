// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "chat" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/chat-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// TypingIndicator — seam:fields
class ForgeTypingIndicator extends StatelessWidget {
  const ForgeTypingIndicator({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.fromLTRB(2, 4, 2, 4), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 9, children: [Container(padding: const EdgeInsets.fromLTRB(15, 12, 15, 12), decoration: BoxDecoration(color: skin.surface, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 5, children: [Container(width: 7, height: 7, decoration: BoxDecoration(color: theme.a, borderRadius: BorderRadius.circular(999))), Container(width: 7, height: 7, decoration: BoxDecoration(color: theme.a, borderRadius: BorderRadius.circular(999))), Container(width: 7, height: 7, decoration: BoxDecoration(color: theme.a, borderRadius: BorderRadius.circular(999)))]))])), Directionality(textDirection: TextDirection.ltr, child: Container(margin: const EdgeInsets.fromLTRB(0, 12, 0, 0), child: Text("three dots breathe · reduced-motion parks them", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 10))))]));
  }
}
