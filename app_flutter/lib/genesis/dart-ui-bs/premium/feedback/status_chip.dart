// ✨ StatusChip — שבב-סטטוס מואר עם מסגרת-שקופה; דאטה: String label + int tone (0..3)
import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final int tone;
  const StatusChip({super.key, required this.label, this.tone = 0});

  static const List<Color> _tones = [
    Color(0xFF7C3AED), // 0 accent
    Color(0xFF34D399), // 1 success
    Color(0xFFF43F5E), // 2 danger
    Color(0xFFF59E0B), // 3 warning
  ];

  @override
  Widget build(BuildContext context) {
    final Color c = _tones[tone % _tones.length];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [c.withValues(alpha: 0.28), c.withValues(alpha: 0.10)],
          ),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: c.withValues(alpha: 0.55), width: 1),
          boxShadow: [
            BoxShadow(color: c.withValues(alpha: 0.30), blurRadius: 12),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: c.withValues(alpha: 0.9), blurRadius: 8),
                ],
              ),
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFF2F3FF),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
