// 🛗 הורם ע"י מנוע-המדף v2 (shelf-lift) — verbatim מהמקור, אל תערוך ידנית.
// מוצא: screens__worker_report_drilldowns:_MiniStatusPill (בנייה-חכמה main) · Stateless
import 'package:flutter/material.dart';
import 'bs_tokens.dart';

class MiniStatusPill extends StatelessWidget {
  const MiniStatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      'done' => (const Color(0xFFD7F5DF), const Color(0xFF1F8A4C)),
      'rejected' => (const Color(0xFFFFE4E4), const Color(0xFFB42318)),
      'review' => (const Color(0xFFFFF0E3), BsTokens.brandDark),
      'active' => (const Color(0xFFE3F0FF), const Color(0xFF1D5FB5)),
      _ => (const Color(0xFFF0F0F0), BsTokens.mutedLight), // pending
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(BsTokens.radiusPill),
      ),
      child: Text(
        kTaskStatusLabel[status] ?? status,
        style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 11),
      ),
    );
  }
}
