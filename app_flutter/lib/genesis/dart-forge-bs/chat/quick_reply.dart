// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "chat" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/chat-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// QuickReply — seam:fields · 4 חריצים
class ForgeQuickReply extends StatelessWidget {
  /// תפר-דאטה (G12a): 4 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 4;
  static const List<String> fieldDemo = <String>["Label", "Label", "Value", "Label"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  const ForgeQuickReply({super.key, this.fields});
  @override
  Widget build(BuildContext context) {
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), child: Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [Container(constraints: const BoxConstraints(minHeight: 38), padding: const EdgeInsets.fromLTRB(14, 8, 14, 8), decoration: BoxDecoration(color: theme.a.withValues(alpha: 0.100), border: Border.all(color: theme.a800), borderRadius: BorderRadius.circular(999)), child: Text(_f(0, "Label"), style: TextStyle(color: theme.aHi, fontFamily: fonts.he, fontSize: 12.5))), Container(constraints: const BoxConstraints(minHeight: 38), padding: const EdgeInsets.fromLTRB(14, 8, 14, 8), decoration: BoxDecoration(color: theme.a.withValues(alpha: 0.100), border: Border.all(color: theme.a800), borderRadius: BorderRadius.circular(999)), child: Text(_f(1, "Label"), style: TextStyle(color: theme.aHi, fontFamily: fonts.he, fontSize: 12.5))), Container(constraints: const BoxConstraints(minHeight: 38), padding: const EdgeInsets.fromLTRB(14, 8, 14, 8), decoration: BoxDecoration(color: theme.a.withValues(alpha: 0.100), border: Border.all(color: theme.a800), borderRadius: BorderRadius.circular(999)), child: Text(_f(2, "Value"), style: TextStyle(color: theme.aHi, fontFamily: fonts.he, fontSize: 12.5))), Container(constraints: const BoxConstraints(minHeight: 38), padding: const EdgeInsets.fromLTRB(14, 8, 14, 8), decoration: BoxDecoration(color: theme.a.withValues(alpha: 0.100), border: Border.all(color: theme.a800), borderRadius: BorderRadius.circular(999)), child: Text(_f(3, "Label"), style: TextStyle(color: theme.aHi, fontFamily: fonts.he, fontSize: 12.5)))]));
  }
}
