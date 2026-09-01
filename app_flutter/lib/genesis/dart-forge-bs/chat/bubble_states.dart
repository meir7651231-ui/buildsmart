// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "chat" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/chat-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

// אייקון-פלייסהולדר ניטרלי (SVG המקורי אינו מתורגם — נשמר כתצורה, לא כפיקסל)
Widget _icon(Color c) => Icon(Icons.circle_outlined, size: 15, color: c);

/// Bubble states — seam:fields
class ForgeBubbleStates extends StatelessWidget {
  const ForgeBubbleStates({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 10, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 5, children: [Container(padding: const EdgeInsets.fromLTRB(13, 9, 13, 7), decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Text("14:20")])), Text("incoming")]), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 5, children: [Container(padding: const EdgeInsets.fromLTRB(13, 9, 13, 7), decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("14:21", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Row(mainAxisSize: MainAxisSize.min, children: [_icon(skin.mut)])])])), Text("outgoing")]), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, spacing: 5, children: [Container(padding: const EdgeInsets.fromLTRB(13, 9, 13, 7), decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Label", style: TextStyle(color: skin.ink, fontFamily: fonts.he)), Text("now")])), Text("sending")])]));
  }
}
