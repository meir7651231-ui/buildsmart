// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__worker_equipment_checklist_sheet:_SecH (בנייה-חכמה main) · Stateless
// משרת-גם (זהה-מבנית): screens__worker_report_drilldowns:_GroupHeader · screens__worker_task_detail_sheet:_SecH
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class WorkerEquipmentChecklistSheetSecH extends StatelessWidget {
  const WorkerEquipmentChecklistSheetSecH(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BsTokens.space1),
      child: Text(
        text,
        style: const TextStyle(
          color: BsTokens.inkLight,
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
      ),
    );
  }
}
