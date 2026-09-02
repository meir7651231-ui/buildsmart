// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "media" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/media-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// AvatarFallback — seam:fields
class ForgeAvatarFallback extends StatelessWidget {
  const ForgeAvatarFallback({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(constraints: const BoxConstraints(minHeight: 120), padding: const EdgeInsets.fromLTRB(22, 22, 22, 22), decoration: BoxDecoration(color: skin.sunken, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(12)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 8, children: [Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.raised2, skin.surface], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(50)), child: Text("L", style: TextStyle(color: skin.mut, fontFamily: fonts.grotesk, fontWeight: FontWeight.w700, height: 1))), Text("no avatar", style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontSize: 10))]));
  }
}
