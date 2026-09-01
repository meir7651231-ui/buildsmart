// ✨ ToastCard — כרטיס-טוסט זכוכית/גרדיאנט עם glyph + tone; דאטה: String message, int tone, String? glyph
import 'package:flutter/material.dart';

class ToastCard extends StatelessWidget {
  final String message;
  final int tone;
  final String? glyph;
  const ToastCard({super.key, required this.message, this.tone = 0, this.glyph});

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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              const Color(0xFF181328).withValues(alpha: 0.96),
              const Color(0xFF120E22).withValues(alpha: 0.96),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.withValues(alpha: 0.5), width: 1),
          boxShadow: [
            BoxShadow(color: c.withValues(alpha: 0.35), blurRadius: 22, offset: const Offset(0, 8)),
            BoxShadow(color: Colors.black.withValues(alpha: 0.45), blurRadius: 30, offset: const Offset(0, 12)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [c.withValues(alpha: 0.9), c.withValues(alpha: 0.5)],
                ),
                boxShadow: [BoxShadow(color: c.withValues(alpha: 0.6), blurRadius: 12)],
              ),
              child: Text(glyph ?? '•', style: const TextStyle(fontSize: 16, color: Colors.white)),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                message,
                style: const TextStyle(
                  color: Color(0xFFF2F3FF),
                  fontSize: 13.5,
                  height: 1.3,
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
