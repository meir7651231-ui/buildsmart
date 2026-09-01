// ✨ StatRow — שורת-סטטיסטיקה: תווית + פס-התקדמות-ניאון (fraction 0..1) + ערך
import 'package:flutter/material.dart';

class StatRow extends StatelessWidget {
  final String label;
  final String value;
  final double fraction;

  const StatRow({
    super.key,
    required this.label,
    required this.value,
    required this.fraction,
  });

  static const Color _card = Color(0xFF101127);
  static const Color _accent = Color(0xFF7C3AED);
  static const Color _text = Color(0xFFF2F3FF);
  static const Color _muted = Color(0xFF9AA0BE);

  @override
  Widget build(BuildContext context) {
    final double f = fraction.clamp(0.0, 1.0);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  value,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    Container(
                      height: 8,
                      width: constraints.maxWidth * f,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        gradient: const LinearGradient(
                          colors: [_accent, Color(0xFFEC4899)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _accent.withValues(alpha: 0.55),
                            blurRadius: 10,
                            spreadRadius: -1,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
