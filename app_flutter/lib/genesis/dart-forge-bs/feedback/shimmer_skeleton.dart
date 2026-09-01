// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "feedback" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/feedback-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// ShimmerSkeleton — seam:fields
class ForgeShimmerSkeleton extends StatelessWidget {
  const ForgeShimmerSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 10, children: [Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.raised, skin.raised2, skin.raised], begin: Alignment.centerLeft, end: Alignment.centerRight), borderRadius: BorderRadius.circular(7))), Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.raised, skin.raised2, skin.raised], begin: Alignment.centerLeft, end: Alignment.centerRight), borderRadius: BorderRadius.circular(7))), Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.raised, skin.raised2, skin.raised], begin: Alignment.centerLeft, end: Alignment.centerRight), borderRadius: BorderRadius.circular(7)))]);
  }
}
