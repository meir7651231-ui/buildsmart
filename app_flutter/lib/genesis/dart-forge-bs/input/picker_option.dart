// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "input" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/input-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// PickerOption — seam:fields · 2 חריצים
class ForgePickerOption extends StatelessWidget {
  /// תפר-דאטה (G12a): 2 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 2;
  static const List<String> fieldDemo = <String>["Label", "Meta"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  const ForgePickerOption({super.key, this.fields});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(13, 11, 13, 11), decoration: BoxDecoration(color: theme.a.withValues(alpha: 0.100), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 11, children: [Container(width: 19, height: 19, alignment: Alignment.center, decoration: BoxDecoration(border: Border.all(color: skin.hair, width: 2), borderRadius: BorderRadius.circular(999))), Expanded(child: Text(_f(0, "Label"), textAlign: TextAlign.right, style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w600))), Flexible(child: Directionality(textDirection: TextDirection.ltr, child: Text(_f(1, "Meta"), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 9.5), overflow: TextOverflow.ellipsis, softWrap: false)))]));
  }
}
