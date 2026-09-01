// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "list" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/list-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// 4 atoms — seam:fields
class Forge4Atoms extends StatelessWidget {
  const Forge4Atoms({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    return Container(decoration: BoxDecoration(color: skin.surface, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(15)), child: Container(padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 15), child: Row(mainAxisSize: MainAxisSize.min, spacing: 12, children: [Container(padding: const EdgeInsets.all(0), decoration: BoxDecoration(color: skin.raised2, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(999))), Row(mainAxisSize: MainAxisSize.min, spacing: 14, children: [Text("inherit SwitchRow →"), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("DsToggleTile"), Text("NotifSettingsSwitchRow"), Text("ChatSettingsSwitchRow"), Text("CourierSettingsSwitchRow")])])])));
  }
}
