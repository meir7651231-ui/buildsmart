// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "nav" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/nav-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// ImageFacePager — seam:collection
class ForgeImageFacePager extends StatelessWidget {
  const ForgeImageFacePager({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    return Container(padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(14)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 11, children: [Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 7, children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: skin.raised2, borderRadius: BorderRadius.circular(50))), Container(width: 8, height: 8, decoration: BoxDecoration(color: skin.raised2, borderRadius: BorderRadius.circular(50))), Container(width: 8, height: 8, decoration: BoxDecoration(color: skin.raised2, borderRadius: BorderRadius.circular(50))), Container(width: 8, height: 8, decoration: BoxDecoration(color: skin.raised2, borderRadius: BorderRadius.circular(50)))]), Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 8, children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: skin.raised2, borderRadius: BorderRadius.circular(10))), Container(width: 40, height: 40, decoration: BoxDecoration(color: skin.raised2, borderRadius: BorderRadius.circular(10))), Container(width: 40, height: 40, decoration: BoxDecoration(color: skin.raised2, borderRadius: BorderRadius.circular(10))), Container(width: 40, height: 40, decoration: BoxDecoration(color: skin.raised2, borderRadius: BorderRadius.circular(10)))])]));
  }
}
