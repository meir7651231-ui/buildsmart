// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "input" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/input-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// Field — seam:fields
class ForgeField extends StatelessWidget {
  /// G13a · תוכן-נוסף בתוך מסגרת-האטום, אחרי זרימת-העיצוב (מקטע/כרטיס ⇒ תוכן-המודול). null ⇒ האטום לבדו.
  final Widget? child;
  /// G13a · שדה-חי (TextField וכו׳) במקום ציור-ה-input של הגלריה. null ⇒ הציור.
  final Widget? control;
  const ForgeField({super.key, this.child, this.control});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    final Widget body = Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 6, children: [SizedBox(width: double.infinity, child: (control == null ? Directionality(textDirection: TextDirection.rtl, child: SizedBox(width: double.infinity, child: Container(height: 44, constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.fromLTRB(13, 0, 13, 0), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: Align(alignment: Alignment.centerRight, child: Text("Value", style: TextStyle(color: skin.faint, fontFamily: fonts.he, fontSize: 13)))))) : Padding(padding: const EdgeInsets.fromLTRB(13, 0, 13, 0), child: control!)))]);
    return body;
  }
}
