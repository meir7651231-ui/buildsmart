// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "card" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/card-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// OutlinedCardSection — seam:fields
class ForgeOutlinedCardSection extends StatelessWidget {
  const ForgeOutlinedCardSection({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(constraints: const BoxConstraints(minHeight: 130), decoration: BoxDecoration(border: Border.all(color: theme.a.withValues(alpha: 0.40), width: 1.5), borderRadius: BorderRadius.circular(16)), child: Stack(clipBehavior: Clip.none, children: [Padding(padding: const EdgeInsets.fromLTRB(18, 18, 18, 18), child: Container(margin: const EdgeInsets.fromLTRB(0, 16, 0, 0), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 14, fontWeight: FontWeight.w600)), Container(margin: const EdgeInsets.fromLTRB(0, 3, 0, 0), child: Text("Meta", style: TextStyle(color: skin.mut, fontSize: 11.5, fontFamily: fonts.he)))]))), Positioned(top: 14, left: 14, child: Directionality(textDirection: TextDirection.ltr, child: Text("OUTLINED", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 8, letterSpacing: 1))))]));
  }
}
