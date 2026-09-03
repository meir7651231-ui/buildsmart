// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "action" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/action-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// SaveDraftButton — seam:fields
class ForgeSaveDraftButton extends StatelessWidget {
  const ForgeSaveDraftButton({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(height: 44, decoration: BoxDecoration(color: skin.raised, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: Center(widthFactor: 1.0, child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 0), child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, spacing: 7, children: [Text("Action", style: TextStyle(color: skin.ink, fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w700))])), Positioned(top: 0, left: 0, right: 0, child: Container(height: 1.2, decoration: BoxDecoration(color: const Color(0xB3FFFFFF))))])));
  }
}
