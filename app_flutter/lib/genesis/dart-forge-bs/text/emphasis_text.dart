// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "text" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/text-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// EmphasisText — seam:fields
class ForgeEmphasisText extends StatelessWidget {
  const ForgeEmphasisText({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(24, 22, 24, 22), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text.rich(TextSpan(children: [TextSpan(text: "טקסט ראשי בדגש", style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 15, fontWeight: FontWeight.w600, height: 1.9)), TextSpan(text: " נושא את המשקל, ", style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 15, height: 1.9)), TextSpan(text: "טקסט משני מוסר הקשר", style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 15, height: 1.9)), TextSpan(text: ", ו", style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 15, height: 1.9)), TextSpan(text: "טקסט עמום נושא מטא-דאטה", style: TextStyle(color: skin.faint, fontFamily: fonts.he, fontSize: 15, height: 1.9)), TextSpan(text: " בשוליים — שלוש דרגות מאותו טוקן.", style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 15, height: 1.9))])), Container(margin: const EdgeInsets.fromLTRB(0, 16, 0, 0), child: Wrap(spacing: 10, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [Directionality(textDirection: TextDirection.ltr, child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 8, children: [Container(width: 12, height: 12, decoration: BoxDecoration(color: skin.ink, borderRadius: BorderRadius.circular(4))), Text("--ink", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 10))])), Directionality(textDirection: TextDirection.ltr, child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 8, children: [Container(width: 12, height: 12, decoration: BoxDecoration(color: skin.mut, borderRadius: BorderRadius.circular(4))), Text("--mut", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 10))])), Directionality(textDirection: TextDirection.ltr, child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 8, children: [Container(width: 12, height: 12, decoration: BoxDecoration(color: skin.faint, borderRadius: BorderRadius.circular(4))), Text("--faint", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontSize: 10))]))]))]));
  }
}
