// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "media" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/media-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// 12 atoms — seam:series
class Forge12Atoms extends StatelessWidget {
  const Forge12Atoms({super.key});
  @override
  Widget build(BuildContext context) {
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Row(mainAxisSize: MainAxisSize.min, spacing: 14, children: [Text("L", style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.grotesk, fontWeight: FontWeight.w700)), Text("inherit Avatar →"), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Avatar"), Text("AvatarGroup"), Text("AvatarStack"), Text("ProfileAvatar"), Text("UserAvatar"), Text("StoryRing"), Text("ImageFacePager"), Text("GalleryThumb"), Text("ProofThumb"), Text("ThumbPlaceholder"), Text("GalleryAllBtn"), Text("FacePile")])]);
  }
}
