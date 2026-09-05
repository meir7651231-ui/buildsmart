// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "input" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/input-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// NumberStepper — seam:fields · מצבים חיים · 9 חריצים
enum ForgeNumberStepperState { defaultLive, focus, minDisabled }

class ForgeNumberStepper extends StatelessWidget {
  final ForgeNumberStepperState state;
  /// תפר-דאטה (G12a): 9 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 9;
  static const List<String> fieldDemo = <String>["−", "2", "+", "−", "3", "+", "−", "0", "+"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  const ForgeNumberStepper({super.key, this.state = ForgeNumberStepperState.defaultLive, this.fields});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return switch (state) {
      ForgeNumberStepperState.defaultLive => Container(decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [Container(width: 42, height: 44, alignment: Alignment.center, child: Text(_f(0, "−"), style: TextStyle(color: skin.ink, fontSize: 18, fontFamily: fonts.he))), Directionality(textDirection: TextDirection.ltr, child: Container(constraints: const BoxConstraints(minWidth: 46), child: Text(_f(1, "2"), textAlign: TextAlign.center, style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 16, fontWeight: FontWeight.w600)))), Container(width: 42, height: 44, alignment: Alignment.center, child: Text(_f(2, "+"), style: TextStyle(color: skin.ink, fontSize: 18, fontFamily: fonts.he)))])),
      ForgeNumberStepperState.focus => Container(decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11), boxShadow: [BoxShadow(color: theme.gl, offset: const Offset(0, 0), blurRadius: 0, spreadRadius: 3)]), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [Container(width: 42, height: 44, alignment: Alignment.center, child: Text(_f(3, "−"), style: TextStyle(color: skin.ink, fontSize: 18, fontFamily: fonts.he))), Directionality(textDirection: TextDirection.ltr, child: Container(constraints: const BoxConstraints(minWidth: 46), child: Text(_f(4, "3"), textAlign: TextAlign.center, style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 16, fontWeight: FontWeight.w600)))), Container(width: 42, height: 44, alignment: Alignment.center, child: Text(_f(5, "+"), style: TextStyle(color: skin.ink, fontSize: 18, fontFamily: fonts.he)))])),
      ForgeNumberStepperState.minDisabled => Container(decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [Opacity(opacity: 0.35, child: Container(width: 42, height: 44, alignment: Alignment.center, child: Text(_f(6, "−"), style: TextStyle(color: skin.ink, fontSize: 18, fontFamily: fonts.he)))), Directionality(textDirection: TextDirection.ltr, child: Container(constraints: const BoxConstraints(minWidth: 46), child: Text(_f(7, "0"), textAlign: TextAlign.center, style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 16, fontWeight: FontWeight.w600)))), Container(width: 42, height: 44, alignment: Alignment.center, child: Text(_f(8, "+"), style: TextStyle(color: skin.ink, fontSize: 18, fontFamily: fonts.he)))])),
    };
  }
}
