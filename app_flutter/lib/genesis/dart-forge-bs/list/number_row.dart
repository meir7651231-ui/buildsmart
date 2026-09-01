// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "list" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/list-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// NumberRow — seam:fields
class ForgeNumberRow extends StatelessWidget {
  const ForgeNumberRow({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    return Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(15)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15), child: Row(mainAxisSize: MainAxisSize.min, spacing: 12, children: [Text("Label"), Text("248")])), Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15), child: Row(mainAxisSize: MainAxisSize.min, spacing: 12, children: [Text("Label"), Text("1,024")])), Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15), child: Row(mainAxisSize: MainAxisSize.min, spacing: 12, children: [Text("Label"), Text("14")]))]));
  }
}
