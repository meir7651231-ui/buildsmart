// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "feedback" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/feedback-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// DraftBadge — seam:fields
class ForgeDraftBadge extends StatelessWidget {
  const ForgeDraftBadge({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 20, children: [Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(8, 3, 8, 3), decoration: BoxDecoration(color: skin.warn.withValues(alpha: 0.14), border: Border.all(color: skin.warn.withValues(alpha: 0.34)), borderRadius: BorderRadius.circular(999)), child: Text("DRAFT", style: TextStyle(color: skin.warn, fontFamily: fonts.grotesk, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 5)))), Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(8, 3, 8, 3), decoration: BoxDecoration(color: theme.a.withValues(alpha: 0.14), border: Border.all(color: theme.a.withValues(alpha: 0.32)), borderRadius: BorderRadius.circular(999)), child: Text("WIP", style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 5)))), Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(8, 3, 8, 3), decoration: BoxDecoration(color: skin.ok.withValues(alpha: 0.14), border: Border.all(color: skin.ok.withValues(alpha: 0.34)), borderRadius: BorderRadius.circular(999)), child: Text("LIVE", style: TextStyle(color: skin.ok, fontFamily: fonts.grotesk, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 5))))]);
  }
}
