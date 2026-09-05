// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "composite" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/composite-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// 6 row atoms — seam:fields · 7 חריצים
class Forge6RowAtoms extends StatelessWidget {
  /// תפר-דאטה (G12a): 7 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 7;
  static const List<String> fieldDemo = <String>["INHERIT SETTINGSGROUP →", "SettingsSwitchRow", "SettingsSectionTile", "SettingsRadioGroupRow", "SettingsTimeRow", "SettingsActionRow", "RegressionPanelCheckRow"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  const Forge6RowAtoms({super.key, this.fields});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return SizedBox(width: double.infinity, child: Wrap(spacing: 14, runSpacing: 14, crossAxisAlignment: WrapCrossAlignment.center, children: [Directionality(textDirection: TextDirection.ltr, child: Text(_f(0, "INHERIT SETTINGSGROUP →"), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 9, letterSpacing: 1))), Wrap(spacing: 6, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(9, 4, 9, 4), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Text(_f(1, "SettingsSwitchRow"), style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 10)))), Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(9, 4, 9, 4), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Text(_f(2, "SettingsSectionTile"), style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 10)))), Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(9, 4, 9, 4), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Text(_f(3, "SettingsRadioGroupRow"), style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 10)))), Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(9, 4, 9, 4), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Text(_f(4, "SettingsTimeRow"), style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 10)))), Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(9, 4, 9, 4), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Text(_f(5, "SettingsActionRow"), style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 10)))), Directionality(textDirection: TextDirection.ltr, child: Container(padding: const EdgeInsets.fromLTRB(9, 4, 9, 4), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999)), child: Text(_f(6, "RegressionPanelCheckRow"), style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 10))))])]));
  }
}
