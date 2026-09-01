// ✨ AlertBanner — באנר-התראה זכוכית עם glyph + פס-tone; דאטה: String message, int tone, String? glyph
import 'package:flutter/material.dart';

class AlertBanner extends StatelessWidget {
  final String message;
  final int tone;
  final String? glyph;
  const AlertBanner({super.key, required this.message, this.tone = 0, this.glyph});

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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [c.withValues(alpha: 0.22), c.withValues(alpha: 0.06)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.withValues(alpha: 0.45), width: 1),
          boxShadow: [
            BoxShadow(color: c.withValues(alpha: 0.22), blurRadius: 18, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 34,
              margin: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                color: c,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [BoxShadow(color: c.withValues(alpha: 0.8), blurRadius: 8)],
              ),
            ),
            if (glyph != null) ...[
              Text(glyph!, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Color(0xFFF2F3FF),
                  fontSize: 13.5,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
