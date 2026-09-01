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
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 14, children: [Container(height: 34, padding: const EdgeInsets.fromLTRB(12, 0, 12, 0), decoration: BoxDecoration(gradient: LinearGradient(colors: [theme.aHi, theme.a, theme.a800], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(9), boxShadow: [BoxShadow(color: const Color(0x66000000), offset: const Offset(0, 1), blurRadius: 2, spreadRadius: 0), BoxShadow(color: theme.gl, offset: const Offset(0, 7), blurRadius: 18, spreadRadius: 0)]), child: Text("Action", style: TextStyle(color: const Color(0xFF0B0B0D), fontFamily: fonts.he, fontSize: 12, fontWeight: FontWeight.w700))), Text("inherit PrimaryBtn →"), Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("ProposePrimaryBtn"), Text("DsPrimaryButton"), Text("AssignButton"), Text("GateButton"), Text("ApprovalButton"), Text("DecideButton"), Text("AdvanceButton"), Text("NewTaskButton"), Text("ProposeTaskButton"), Text("EquipmentButton"), Text("VehicleButton"), Text("LocationButton"), Text("LogButton"), Text("AiCardBtn"), Text("BigButton"), Text("WorkerTaskDetailSheetPrimaryBtn"), Text("WorkerEquipmentChecklistSheetPrimaryBtn"), Text("CourierAttendanceSendReportButton")])]);
  }
}
