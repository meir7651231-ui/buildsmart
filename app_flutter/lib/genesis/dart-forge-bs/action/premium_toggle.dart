// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "action" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/action-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// PremiumToggle — seam:fields
class ForgePremiumToggle extends StatelessWidget {
  const ForgePremiumToggle({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    return Container(padding: const EdgeInsets.fromLTRB(0, 4, 0, 2), child: Row(mainAxisSize: MainAxisSize.min, spacing: 18, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 8, children: [Container(padding: const EdgeInsets.all(3), decoration: BoxDecoration(color: theme.aHi, border: Border.all(color: const Color(0x2EFFFFFF)), borderRadius: BorderRadius.circular(999)), child: const SizedBox.shrink()), Text("on")]), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 8, children: [Container(padding: const EdgeInsets.all(3), decoration: BoxDecoration(color: theme.aHi, border: Border.all(color: const Color(0x2EFFFFFF)), borderRadius: BorderRadius.circular(999)), child: const SizedBox.shrink()), Text("off")]), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 8, children: [Container(padding: const EdgeInsets.all(3), decoration: BoxDecoration(color: theme.aHi, border: Border.all(color: const Color(0x2EFFFFFF)), borderRadius: BorderRadius.circular(999)), child: const SizedBox.shrink()), Text("focus")]), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 8, children: [Container(padding: const EdgeInsets.all(3), decoration: BoxDecoration(color: theme.aHi, border: Border.all(color: const Color(0x2EFFFFFF)), borderRadius: BorderRadius.circular(999)), child: const SizedBox.shrink()), Text("disabled")])]));
  }
}
