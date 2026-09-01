// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "feedback" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/feedback-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// DraftBadge — seam:fields
class ForgeDraftBadge extends StatelessWidget {
  const ForgeDraftBadge({super.key});
  @override
  Widget build(BuildContext context) {
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Row(mainAxisSize: MainAxisSize.min, spacing: 20, children: [Text("DRAFT", style: TextStyle(fontFamily: fonts.grotesk, fontSize: 10, fontWeight: FontWeight.w700)), Text("WIP", style: TextStyle(fontFamily: fonts.grotesk, fontSize: 10, fontWeight: FontWeight.w700)), Text("LIVE", style: TextStyle(fontFamily: fonts.grotesk, fontSize: 10, fontWeight: FontWeight.w700))]);
  }
}
