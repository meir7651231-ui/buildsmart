// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "action" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/action-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// StoreStepBtn — seam:fields
class ForgeStoreStepBtn extends StatelessWidget {
  const ForgeStoreStepBtn({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Text.rich(TextSpan(children: [TextSpan(text: "QTY", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 9, letterSpacing: 1)), WidgetSpan(alignment: PlaceholderAlignment.middle, child: Container(decoration: BoxDecoration(color: skin.raised, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [Container(width: 38, height: 44, alignment: Alignment.center, child: Text("−", style: TextStyle(color: skin.ink, fontSize: 17, fontFamily: fonts.he))), Container(constraints: const BoxConstraints(minWidth: 40), child: Text("1", textAlign: TextAlign.center, style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontWeight: FontWeight.w600))), Container(width: 38, height: 44, alignment: Alignment.center, child: Text("+", style: TextStyle(color: skin.ink, fontSize: 17, fontFamily: fonts.he)))])))]));
  }
}
