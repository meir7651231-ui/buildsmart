// ✨ MediaRow — שורת-מדיה: אייקון-גרדיאנט + כותרת/תת-כותרת + trailing אופציונלי
import 'package:flutter/material.dart';

class MediaRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String glyph;
  final String? trailing;

  const MediaRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.glyph,
    this.trailing,
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
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_accent, Color(0xFF4338CA)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _accent.withValues(alpha: 0.45),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(glyph, style: const TextStyle(fontSize: 22)),
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
                if (trailing != null) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      trailing!,
                      style: const TextStyle(
                        color: Color(0xFFC4B5FD),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
