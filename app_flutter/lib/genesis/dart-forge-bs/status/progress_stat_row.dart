// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "status" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/status-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// ProgressStatRow — seam:fields · 2 חריצים
class ForgeProgressStatRow extends StatelessWidget {
  /// תפר-דאטה (G12a): 2 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 2;
  static const List<String> fieldDemo = <String>["Label", "4 / 6"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  const ForgeProgressStatRow({super.key, this.fields});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(0, 6, 0, 6), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [Flexible(child: Text(_f(0, "Label"), style: TextStyle(color: skin.ink, fontSize: 16, fontFamily: fonts.he), overflow: TextOverflow.ellipsis, softWrap: false)), Flexible(child: Text(_f(1, "4 / 6"), style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 16), overflow: TextOverflow.ellipsis, softWrap: false))]), const SizedBox(height: 7), Container(height: 9, child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 3, children: [Expanded(child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair2), borderRadius: BorderRadius.circular(2)))), Expanded(child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair2), borderRadius: BorderRadius.circular(2)))), Expanded(child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair2), borderRadius: BorderRadius.circular(2)))), Expanded(child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair2), borderRadius: BorderRadius.circular(2)))), Expanded(child: Container(decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair2), borderRadius: BorderRadius.circular(2)))), Expanded(child: Container(decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair2), borderRadius: BorderRadius.circular(2))))]))]));
  }
}
