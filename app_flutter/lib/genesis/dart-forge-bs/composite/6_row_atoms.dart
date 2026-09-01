// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "composite" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/composite-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';

/// 6 row atoms — seam:fields
class Forge6RowAtoms extends StatelessWidget {
  const Forge6RowAtoms({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, spacing: 14, children: [Text("inherit SettingsGroup →"), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("SettingsSwitchRow"), Text("SettingsSectionTile"), Text("SettingsRadioGroupRow"), Text("SettingsTimeRow"), Text("SettingsActionRow"), Text("RegressionPanelCheckRow")])]);
  }
}
