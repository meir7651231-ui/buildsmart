// 🧼 אטום-משותף · BareStat — סטטיסטיקה חשופה בלי-כרטיס (איחד _TodayStat/_DayStat ×3).
// מוצא: courier_attendance_screen.dart · verbatim, טוקנים מוזרקים.
import 'package:flutter/material.dart';

class BareStat extends StatelessWidget {
  const BareStat({
    required this.value, required this.label,
    required this.inkColor, required this.mutedColor, super.key,
  });
  final String value, label;
  final Color inkColor, mutedColor;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(children: [
          Text(value, style: TextStyle(color: inkColor, fontWeight: FontWeight.w800, fontSize: 17)),
          Text(label, style: TextStyle(color: mutedColor, fontSize: 12)),
        ]),
      );
}
