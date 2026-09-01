// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "composite" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/composite-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';

/// 8 assemblies — seam:fields
class Forge8Assemblies extends StatelessWidget {
  const Forge8Assemblies({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, spacing: 14, children: [Text("inherit FormCard →"), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("FamilyForm"), Text("CourseForm"), Text("SupporterForm"), Text("DonationModal"), Text("RoomForm"), Text("ManageModal"), Text("CallbackModal"), Text("IntakePanel")])]);
  }
}
