// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "input" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/input-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// FieldLabel — seam:fields · 3 חריצים
class ForgeFieldLabel extends StatelessWidget {
  /// תפר-דאטה (G12a): 3 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 3;
  static const List<String> fieldDemo = <String>["Label", "*", "Meta · required label atom"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  const ForgeFieldLabel({super.key, this.fields});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Text.rich(TextSpan(children: [WidgetSpan(alignment: PlaceholderAlignment.middle, child: Text.rich(TextSpan(children: [TextSpan(text: _f(0, "Label"), style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w600)), WidgetSpan(alignment: PlaceholderAlignment.middle, child: Container(margin: const EdgeInsets.fromLTRB(0, 0, 2, 0), child: Text(_f(1, "*"), style: TextStyle(color: theme.aHi, fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w600))))]), textAlign: TextAlign.right)), WidgetSpan(alignment: PlaceholderAlignment.middle, child: Text(_f(2, "Meta · required label atom"), textAlign: TextAlign.right, style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 9.5)))]));
  }
}
