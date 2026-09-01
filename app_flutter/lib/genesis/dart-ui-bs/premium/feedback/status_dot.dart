// ✨ StatusDot — נקודת-סטטוס זוהרת עם הילה כפולה; דאטה: int tone (0..3) + size
import 'package:flutter/material.dart';

class StatusDot extends StatelessWidget {
  final int tone;
  final double size;
  const StatusDot({super.key, this.tone = 0, this.size = 12});

  static const List<Color> _tones = [
    Color(0xFF22D3EE), // 0 accent (ציאן)
    Color(0xFF34D399), // 1 success
    Color(0xFFF43F5E), // 2 danger
    Color(0xFFF59E0B), // 3 warning
  ];

  @override
  Widget build(BuildContext context) {
    final Color c = _tones[tone % _tones.length];
    return SizedBox(
      width: size * 2,
      height: size * 2,
      child: Center(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [Colors.white.withValues(alpha: 0.9), c],
              stops: const [0.0, 0.85],
            ),
            border: Border.all(color: c.withValues(alpha: 0.6), width: 1),
            boxShadow: [
              BoxShadow(color: c.withValues(alpha: 0.85), blurRadius: 8, spreadRadius: 0.5),
              BoxShadow(color: c.withValues(alpha: 0.45), blurRadius: 16, spreadRadius: 2),
            ],
          ),
        ),
      ),
    );
  }
}
