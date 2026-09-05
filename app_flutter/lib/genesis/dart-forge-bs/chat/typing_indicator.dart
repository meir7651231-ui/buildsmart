// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "chat" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/chat-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// TypingIndicator — seam:fields · 1 חריצים
class ForgeTypingIndicator extends StatelessWidget {
  /// תפר-דאטה (G12a): 1 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 1;
  static const List<String> fieldDemo = <String>["three dots breathe · reduced-motion parks them"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  const ForgeTypingIndicator({super.key, this.fields});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.fromLTRB(2, 4, 2, 4), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 9, children: [Container(padding: const EdgeInsets.fromLTRB(15, 12, 15, 12), decoration: BoxDecoration(color: skin.surface, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 5, children: [Container(width: 7, height: 7, decoration: BoxDecoration(color: theme.a, borderRadius: BorderRadius.circular(999))), Container(width: 7, height: 7, decoration: BoxDecoration(color: theme.a, borderRadius: BorderRadius.circular(999))), Container(width: 7, height: 7, decoration: BoxDecoration(color: theme.a, borderRadius: BorderRadius.circular(999)))]))])), const SizedBox(height: 12), Directionality(textDirection: TextDirection.ltr, child: Text(_f(0, "three dots breathe · reduced-motion parks them"), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 10)))]));
  }
}
