// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "feedback" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/feedback-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// DraftBadge — seam:fields · 3 חריצים
class ForgeDraftBadge extends StatelessWidget {
  /// תפר-דאטה (G12a): 3 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 3;
  static const List<String> fieldDemo = <String>["DRAFT", "WIP", "LIVE"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  const ForgeDraftBadge({super.key, this.fields});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Wrap(spacing: 20, runSpacing: 20, crossAxisAlignment: WrapCrossAlignment.center, children: [Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(8, 3, 8, 3), decoration: BoxDecoration(color: skin.warn.withValues(alpha: 0.140), border: Border.all(color: skin.warn.withValues(alpha: 0.340)), borderRadius: BorderRadius.circular(999)), child: Text(_f(0, "DRAFT"), style: TextStyle(color: skin.warn, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5)))), Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(8, 3, 8, 3), decoration: BoxDecoration(color: theme.a.withValues(alpha: 0.140), border: Border.all(color: theme.a.withValues(alpha: 0.320)), borderRadius: BorderRadius.circular(999)), child: Text(_f(1, "WIP"), style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5)))), Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(8, 3, 8, 3), decoration: BoxDecoration(color: skin.ok.withValues(alpha: 0.140), border: Border.all(color: skin.ok.withValues(alpha: 0.340)), borderRadius: BorderRadius.circular(999)), child: Text(_f(2, "LIVE"), style: TextStyle(color: skin.ok, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5))))]);
  }
}
