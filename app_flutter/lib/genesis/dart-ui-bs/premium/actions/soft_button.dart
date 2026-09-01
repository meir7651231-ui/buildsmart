// ✨ SoftButton — כפתור רך שקוף-גוון עם גבול עדין. tone: 0 accent(סגול)·1 success(ציאן-ירקרק)·2 danger(מגנטה-אדום). מקבל label · onTap · tone.
import 'package:flutter/material.dart';

class SoftButton extends StatelessWidget {
  const SoftButton({
    super.key,
    required this.label,
    this.onTap,
    this.tone = 0,
  });

  final String label;
  final VoidCallback? onTap;
  final int tone;

  static const List<Color> _tones = [
    Color(0xFF7C3AED), // accent
    Color(0xFF2DD4A7), // success
    Color(0xFFF43F5E), // danger
  ];

  @override
  Widget build(BuildContext context) {
    final Color c = _tones[tone % _tones.length];
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: c.withValues(alpha: 0.14),
        border: Border.all(
          color: c.withValues(alpha: 0.42),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: c.withValues(alpha: 0.20),
          highlightColor: c.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsetsDirectional.only(end: 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c,
                    boxShadow: [
                      BoxShadow(
                        color: c.withValues(alpha: 0.7),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: Color.lerp(c, const Color(0xFFF2F3FF), 0.55),
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
