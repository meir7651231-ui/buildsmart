// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "feedback" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/feedback-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

// אייקון-פלייסהולדר ניטרלי (SVG המקורי אינו מתורגם — נשמר כתצורה, לא כפיקסל)
Widget _icon(Color c) => Icon(Icons.circle_outlined, size: 15, color: c);

/// AlertBanner — seam:fields
class ForgeAlertBanner extends StatelessWidget {
  const ForgeAlertBanner({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 10, children: [Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14), decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)), child: Row(mainAxisSize: MainAxisSize.min, spacing: 11, children: [_icon(skin.mut), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Label"), Text("info · morphs with theme")])])), Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14), decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)), child: Row(mainAxisSize: MainAxisSize.min, spacing: 11, children: [_icon(skin.mut), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Label"), Text("success · fixed green")])])), Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14), decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)), child: Row(mainAxisSize: MainAxisSize.min, spacing: 11, children: [_icon(skin.mut), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Label"), Text("warning · fixed amber")])])), Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14), decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)), child: Row(mainAxisSize: MainAxisSize.min, spacing: 11, children: [_icon(skin.mut), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Label"), Text("error · fixed red")])]))]);
  }
}
