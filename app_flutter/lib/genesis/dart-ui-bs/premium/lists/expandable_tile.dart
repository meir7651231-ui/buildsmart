// ✨ ExpandableTile — אריח מתקפל: כותרת + גוף נחשף באנימציה + חץ מסתובב
import 'package:flutter/material.dart';

class ExpandableTile extends StatefulWidget {
  final String title;
  final String body;

  const ExpandableTile({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  State<ExpandableTile> createState() => _ExpandableTileState();
}

class _ExpandableTileState extends State<ExpandableTile>
    with SingleTickerProviderStateMixin {
  static const Color _card = Color(0xFF101127);
  static const Color _accent = Color(0xFF7C3AED);
  static const Color _text = Color(0xFFF2F3FF);
  static const Color _muted = Color(0xFF9AA0BE);

  bool _open = false;

  void _toggle() => setState(() => _open = !_open);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _open
                ? _accent.withValues(alpha: 0.45)
                : Colors.white.withValues(alpha: 0.06),
          ),
          boxShadow: _open
              ? [
                  BoxShadow(
                    color: _accent.withValues(alpha: 0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : const [],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _toggle,
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 14, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _text,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      AnimatedRotation(
                        turns: _open ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _accent.withValues(alpha: 0.16),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFFC4B5FD),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
                child: Text(
                  widget.body,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
              crossFadeState: _open
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 260),
              sizeCurve: Curves.easeOutCubic,
            ),
          ],
        ),
      ),
    );
  }
}
