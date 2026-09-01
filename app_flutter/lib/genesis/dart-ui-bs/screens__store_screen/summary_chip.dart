// 🧼 אטום · SummaryChip — צ׳יפ-סיכום צבעוני; רקע/מסגרת נגזרים מ-color באלפא.
// מוצא: screens__store_screen.dart:644 (_SummaryChip) · verbatim, אפס-דאטה.
// הקופסה מזינה label מפורמט (t_f858a72b / t_c57367d1 / t_e1cc63e1) + פיגמנט.
import 'package:flutter/material.dart';

class SummaryChip extends StatelessWidget {
  const SummaryChip({required this.label, required this.color, super.key});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      );
}
