// ✨ AvatarTile — אריח-אווטאר: ראשי-תיבות בגרדיאנט זוהר + כותרת/תת-כותרת
import 'package:flutter/material.dart';

class AvatarTile extends StatelessWidget {
  final String initials;
  final String title;
  final String subtitle;

  const AvatarTile({
    super.key,
    required this.initials,
    required this.title,
    required this.subtitle,
  });

  static const Color _card = Color(0xFF101127);
  static const Color _accent = Color(0xFF7C3AED);
  static const Color _text = Color(0xFFF2F3FF);
  static const Color _muted = Color(0xFF9AA0BE);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsetsDirectional.fromSTEB(14, 13, 14, 13),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: AlignmentDirectional.centerEnd,
                end: AlignmentDirectional.centerStart,
                colors: [_card, Color(0xFF0C0D1E)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const SweepGradient(
                      colors: [
                        _accent,
                        Color(0xFFEC4899),
                        Color(0xFF4338CA),
                        _accent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _accent.withValues(alpha: 0.5),
                        blurRadius: 18,
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF0C0D1E),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: _text,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _text,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 12.5,
                          height: 1.2,
                        ),
                      ),
                    ],
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
