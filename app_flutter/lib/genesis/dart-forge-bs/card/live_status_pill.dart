// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "card" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/card-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// LiveStatusPill — seam:fields
class ForgeLiveStatusPill extends StatelessWidget {
  const ForgeLiveStatusPill({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(2, 10, 2, 10), child: Wrap(spacing: 14, runSpacing: 14, crossAxisAlignment: WrapCrossAlignment.center, children: [Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(10, 4, 10, 4), decoration: BoxDecoration(color: skin.ok.withValues(alpha: 0.14), border: Border.all(color: skin.ok.withValues(alpha: 0.30)), borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 6, children: [Container(width: 7, height: 7, decoration: BoxDecoration(color: skin.ok, borderRadius: BorderRadius.circular(50))), Text("LIVE", style: TextStyle(color: skin.ok, fontFamily: fonts.grotesk, fontSize: 10, fontWeight: FontWeight.w700))])))]));
  }
}
