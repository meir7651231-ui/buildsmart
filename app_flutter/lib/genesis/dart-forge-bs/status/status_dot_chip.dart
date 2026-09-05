// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "status" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/status-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// StatusDotChip — seam:fields · 2 חריצים
class ForgeStatusDotChip extends StatelessWidget {
  /// תפר-דאטה (G12a): 2 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 2;
  static const List<String> fieldDemo = <String>["Label", "Label"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  const ForgeStatusDotChip({super.key, this.fields});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(2, 8, 2, 8), child: Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [Directionality(textDirection: TextDirection.ltr, child: Container(constraints: const BoxConstraints(minHeight: 26), padding: const EdgeInsets.fromLTRB(11, 5, 11, 5), decoration: BoxDecoration(color: skin.ok.withValues(alpha: 0.140), border: Border.all(color: skin.ok.withValues(alpha: 0.320)), borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 6, children: [Container(width: 6, height: 6, decoration: BoxDecoration(color: skin.ok, borderRadius: BorderRadius.circular(999))), Text(_f(0, "Label"), style: TextStyle(color: skin.ok, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 10.5, fontWeight: FontWeight.w700, height: 1, leadingDistribution: TextLeadingDistribution.even))]))), Directionality(textDirection: TextDirection.ltr, child: Container(constraints: const BoxConstraints(minHeight: 26), padding: const EdgeInsets.fromLTRB(11, 5, 11, 5), decoration: BoxDecoration(color: skin.warn.withValues(alpha: 0.140), border: Border.all(color: skin.warn.withValues(alpha: 0.320)), borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 6, children: [Container(width: 6, height: 6, decoration: BoxDecoration(color: skin.warn, borderRadius: BorderRadius.circular(999))), Text(_f(1, "Label"), style: TextStyle(color: skin.warn, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 10.5, fontWeight: FontWeight.w700, height: 1, leadingDistribution: TextLeadingDistribution.even))])))]));
  }
}
