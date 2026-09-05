// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "temporal" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/temporal-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// MetaTicker — seam:fields · 1 חריצים
class ForgeMetaTicker extends StatelessWidget {
  /// תפר-דאטה (G12a): 1 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 1;
  static const List<String> fieldDemo = <String>["Meta ticker — Label · Value pairs streaming, one row, tabular. Reduced-motion parks it."];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  const ForgeMetaTicker({super.key, this.fields});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Container(decoration: BoxDecoration(color: skin.sunken, border: Border(top: BorderSide(color: skin.hair2, width: 1), bottom: BorderSide(color: skin.hair2, width: 1))), child: const SizedBox.shrink()), Container(padding: const EdgeInsets.fromLTRB(16, 12, 16, 16), child: Directionality(textDirection: TextDirection.ltr, child: Text(_f(0, "Meta ticker — Label · Value pairs streaming, one row, tabular. Reduced-motion parks it."), style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11, fontFeatures: const [FontFeature.tabularFigures()]))))]);
  }
}
