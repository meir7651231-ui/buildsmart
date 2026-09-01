// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "list" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/list-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// NotifRow — seam:fields
class ForgeNotifRow extends StatelessWidget {
  const ForgeNotifRow({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    return Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(15)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15), child: Row(mainAxisSize: MainAxisSize.min, spacing: 12, children: [const SizedBox.shrink(), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Label"), Text("Meta")]), const SizedBox.shrink()])), Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15), child: Row(mainAxisSize: MainAxisSize.min, spacing: 12, children: [const SizedBox.shrink(), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Label"), Text("Meta")]), Text("3")])), Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15), child: Row(mainAxisSize: MainAxisSize.min, spacing: 12, children: [const SizedBox.shrink(), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("Label"), Text("Meta")])]))]));
  }
}
