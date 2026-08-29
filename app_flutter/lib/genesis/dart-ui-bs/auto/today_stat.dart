// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__courier_attendance_screen:_TodayStat (בנייה-חכמה main) · Stateless
// משרת-גם (זהה-מבנית): screens__worker_app_screen:_DayStat · screens__worker_attendance_screen:_TodayStat
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class TodayStat extends StatelessWidget {
  const TodayStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: BsTokens.inkLight,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: BsTokens.mutedLight, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
