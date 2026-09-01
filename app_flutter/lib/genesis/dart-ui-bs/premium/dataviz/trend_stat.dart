// ✨ TrendStat — ערך + תווית + צ׳יפ-מגמה (delta>0 ירוק↑ / <0 אדום↓)
import 'dart:ui';
import 'package:flutter/material.dart';

class TrendStat extends StatelessWidget {
  const TrendStat({
    super.key,
    required this.value,
    required this.delta,
    required this.label,
  });

  final String value;
  final double delta;
  final String label;

  static const Color _bg = Color(0xFF12132A);
  static const Color _ink = Color(0xFFF2F3FF);
  static const Color _mute = Color(0xFF8A8CB8);
  static const Color _up = Color(0xFF3DFFB0);
  static const Color _down = Color(0xFFFF5C7A);

  @override
  Widget build(BuildContext context) {
    final bool flat = delta == 0;
    final bool up = delta > 0;
    final Color accent = flat ? _mute : (up ? _up : _down);
    final String arrow = flat ? '→' : (up ? '↑' : '↓');
    final String pct = '${delta.abs().toStringAsFixed(1)}%';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: _mute,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.4,
                    height: 1,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: accent.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    '$arrow $pct',
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                      color: accent,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
