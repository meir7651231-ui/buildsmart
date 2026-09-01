// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "feedback" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/feedback-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

// אייקון-פלייסהולדר ניטרלי (SVG המקורי אינו מתורגם — נשמר כתצורה, לא כפיקסל)
Widget _icon(Color c) => Icon(Icons.circle_outlined, size: 15, color: c);

/// 5 atoms — seam:fields
class Forge5Atoms extends StatelessWidget {
  const Forge5Atoms({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    return Row(mainAxisSize: MainAxisSize.min, spacing: 14, children: [Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14), decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)), child: Row(mainAxisSize: MainAxisSize.min, spacing: 11, children: [_icon(skin.mut), Text("Label")])), Text("inherit AlertBanner →"), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("TintedBanner"), Text("CoinBanner"), Text("QuickReplyBanner"), Text("RecommendedKitBanner"), Text("PersonaPickingSheetBanner")])]);
  }
}
