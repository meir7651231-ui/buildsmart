// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "card" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/card-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
import 'package:flutter/material.dart';

/// 9 atoms — seam:fields
class Forge9Atoms extends StatelessWidget {
  const Forge9Atoms({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 14, children: [Container(width: 30, height: 30, decoration: BoxDecoration(borderRadius: BorderRadius.circular(9)), child: Text("L", style: TextStyle(fontSize: 12))), Text("inherit DsRecordCard →"), Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text("OrderCard"), Text("CustomerCard"), Text("SupplierTile"), Text("SummaryCard"), Text("ProposalCard"), Text("ApprovalCard"), Text("PenaltyCard"), Text("VacationRequestCard"), Text("DeliveryOptionCard")])]);
  }
}
