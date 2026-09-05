// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "feedback" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/feedback-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// LinearProgress — seam:fields · 1 חריצים
class ForgeLinearProgressFeedback extends StatelessWidget {
  /// תפר-דאטה (G12a): 1 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 1;
  static const List<String> fieldDemo = <String>["62%"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  const ForgeLinearProgressFeedback({super.key, this.fields});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 9, children: [SizedBox(width: double.infinity, child: Container(height: 8, decoration: BoxDecoration(color: skin.raised2, borderRadius: BorderRadius.circular(999)), child: FractionallySizedBox(widthFactor: 0.620, alignment: Alignment.centerRight, child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.centerLeft, end: Alignment.centerRight), borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: theme.gl, offset: const Offset(0, 0), blurRadius: 12, spreadRadius: 0)]))))), Text(_f(0, "62%"), style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11))]);
  }
}
