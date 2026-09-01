// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "chat" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/chat-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

// אייקון-פלייסהולדר ניטרלי (SVG המקורי אינו מתורגם — נשמר כתצורה, לא כפיקסל)
Widget _icon(Color c) => Icon(Icons.circle_outlined, size: 15, color: c);

/// MessageThread — seam:fields
class ForgeMessageThread extends StatelessWidget {
  const ForgeMessageThread({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.all(16), child: Container(padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 9, children: [Text("Meta", style: TextStyle(fontSize: 13.5)), Container(padding: const EdgeInsets.fromLTRB(13, 9, 13, 7), decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Label · Value", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Text("14:31")])), Container(padding: const EdgeInsets.fromLTRB(13, 9, 13, 7), decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("14:32", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Row(mainAxisSize: MainAxisSize.min, children: [_icon(skin.mut)])])])), Container(padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0), child: Row(mainAxisSize: MainAxisSize.min, spacing: 12, children: [Text("Meta")])), Container(padding: const EdgeInsets.fromLTRB(13, 9, 13, 7), decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Text("14:36")])), Container(padding: const EdgeInsets.fromLTRB(13, 9, 13, 7), decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Label · Value · Meta", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("14:38", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Row(mainAxisSize: MainAxisSize.min, children: [_icon(skin.mut)])])]))])));
  }
}
