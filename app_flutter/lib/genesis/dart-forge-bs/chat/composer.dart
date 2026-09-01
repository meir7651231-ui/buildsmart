// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "chat" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/chat-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

// אייקון-פלייסהולדר ניטרלי (SVG המקורי אינו מתורגם — נשמר כתצורה, לא כפיקסל)
Widget _icon(Color c) => Icon(Icons.circle_outlined, size: 15, color: c);

/// Composer — seam:self
class ForgeComposer extends StatelessWidget {
  const ForgeComposer({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.all(16), child: Row(mainAxisSize: MainAxisSize.min, spacing: 10, children: [Container(padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.min, spacing: 10, children: [_icon(skin.mut), Text("Label", style: TextStyle(color: skin.faint, fontFamily: fonts.he, fontSize: 13))])), Container(decoration: BoxDecoration(color: theme.aHi, borderRadius: BorderRadius.circular(50)), child: _icon(skin.mut))]));
  }
}
