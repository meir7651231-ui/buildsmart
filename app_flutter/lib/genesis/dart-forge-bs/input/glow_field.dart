// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "input" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/input-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// GlowField — seam:fields · 1 חריצים
class ForgeGlowField extends StatelessWidget {
  /// תפר-דאטה (G12a): 1 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 1;
  static const List<String> fieldDemo = <String>["Label"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  const ForgeGlowField({super.key, this.fields});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 6, children: [SizedBox(width: double.infinity, child: Text(_f(0, "Label"), textAlign: TextAlign.right, style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 11, fontWeight: FontWeight.w600))), SizedBox(width: double.infinity, child: Directionality(textDirection: TextDirection.rtl, child: SizedBox(width: double.infinity, child: Container(height: 44, constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(13, 0, 13, 0), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11), boxShadow: [BoxShadow(color: theme.gl, offset: const Offset(0, 0), blurRadius: 0, spreadRadius: 3), BoxShadow(color: theme.gl, offset: const Offset(0, 0), blurRadius: 34, spreadRadius: 0), BoxShadow(color: theme.gl, offset: const Offset(0, 0), blurRadius: 66, spreadRadius: 0)]), child: Align(alignment: Alignment.centerRight, child: Text("Value", style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 13)))))))]);
  }
}
