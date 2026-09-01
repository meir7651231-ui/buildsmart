// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "media" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/media-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// StoryRing — seam:fields
class ForgeStoryRing extends StatelessWidget {
  const ForgeStoryRing({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Row(mainAxisSize: MainAxisSize.min, spacing: 14, children: [Container(padding: const EdgeInsets.all(3), decoration: BoxDecoration(color: theme.aHi, borderRadius: BorderRadius.circular(50)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [const SizedBox.shrink(), Text("L", style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.grotesk, fontWeight: FontWeight.w700))])), Container(padding: const EdgeInsets.all(3), decoration: BoxDecoration(color: theme.aHi, borderRadius: BorderRadius.circular(50)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [const SizedBox.shrink(), Text("L", style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.grotesk, fontWeight: FontWeight.w700))]))]);
  }
}
