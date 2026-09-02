// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "status" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/status-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// StatusDotChip — seam:fields
class ForgeStatusDotChip extends StatelessWidget {
  const ForgeStatusDotChip({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(2, 8, 2, 8), child: Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [Directionality(textDirection: TextDirection.ltr, child: Container(constraints: const BoxConstraints(minHeight: 26), padding: const EdgeInsets.fromLTRB(11, 5, 11, 5), decoration: BoxDecoration(color: skin.ok.withValues(alpha: 0.14), border: Border.all(color: skin.ok.withValues(alpha: 0.32)), borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 6, children: [Container(width: 6, height: 6, decoration: BoxDecoration(color: skin.ok, borderRadius: BorderRadius.circular(999))), Text("Label", style: TextStyle(color: skin.ok, fontFamily: fonts.grotesk, fontSize: 10.5, fontWeight: FontWeight.w700, height: 1, leadingDistribution: TextLeadingDistribution.even))]))), Directionality(textDirection: TextDirection.ltr, child: Container(constraints: const BoxConstraints(minHeight: 26), padding: const EdgeInsets.fromLTRB(11, 5, 11, 5), decoration: BoxDecoration(color: skin.warn.withValues(alpha: 0.14), border: Border.all(color: skin.warn.withValues(alpha: 0.32)), borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 6, children: [Container(width: 6, height: 6, decoration: BoxDecoration(color: skin.warn, borderRadius: BorderRadius.circular(999))), Text("Label", style: TextStyle(color: skin.warn, fontFamily: fonts.grotesk, fontSize: 10.5, fontWeight: FontWeight.w700, height: 1, leadingDistribution: TextLeadingDistribution.even))])))]));
  }
}
