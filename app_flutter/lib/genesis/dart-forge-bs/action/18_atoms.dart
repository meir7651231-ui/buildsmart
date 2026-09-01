// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "action" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/action-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

/// 18 atoms — seam:fields
class Forge18Atoms extends StatelessWidget {
  const Forge18Atoms({super.key});
  @override
  Widget build(BuildContext context) {
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Row(mainAxisSize: MainAxisSize.min, spacing: 14, children: [Text("Action", style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.he, fontSize: 13, fontWeight: FontWeight.w700)), Text("inherit PrimaryBtn →"), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text("ProposePrimaryBtn"), Text("DsPrimaryButton"), Text("AssignButton"), Text("GateButton"), Text("ApprovalButton"), Text("DecideButton"), Text("AdvanceButton"), Text("NewTaskButton"), Text("ProposeTaskButton"), Text("EquipmentButton"), Text("VehicleButton"), Text("LocationButton"), Text("LogButton"), Text("AiCardBtn"), Text("BigButton"), Text("WorkerTaskDetailSheetPrimaryBtn"), Text("WorkerEquipmentChecklistSheetPrimaryBtn"), Text("CourierAttendanceSendReportButton")])]);
  }
}
