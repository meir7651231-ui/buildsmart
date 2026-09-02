// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "feedback" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/feedback-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// SkeletonCard — seam:fields
class ForgeSkeletonCard extends StatelessWidget {
  const ForgeSkeletonCard({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    return Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 12, children: [Container(width: 44, height: 44, decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.raised, skin.raised2, skin.raised], begin: Alignment.centerLeft, end: Alignment.centerRight), borderRadius: BorderRadius.circular(12))), Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 10, children: [Container(height: 12, decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.raised, skin.raised2, skin.raised], begin: Alignment.centerLeft, end: Alignment.centerRight), borderRadius: BorderRadius.circular(7))), Container(height: 12, decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.raised, skin.raised2, skin.raised], begin: Alignment.centerLeft, end: Alignment.centerRight), borderRadius: BorderRadius.circular(7)))])]);
  }
}
