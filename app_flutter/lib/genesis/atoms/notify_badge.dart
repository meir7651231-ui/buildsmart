// 🎨 חוט-תצוגה · NotifyBadge — אייקון עם תגית-מונה פועמת (חוק-1/חוק-5).
// המנוע: תגית-הספירה פועמת בסקייל מחזורי (AnimationController) מעל אייקון. אפס-דאטה —
// אייקון · מספר · גובה · צבע-תגית/טקסט/רקע-אייקון מוזרקים בחיווט.
import 'dart:math' as math;
import 'package:flutter/material.dart';

class NotifyBadge extends StatefulWidget {
  const NotifyBadge({
    required this.icon,
    required this.height,
    required this.items,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    super.key,
  });

  final IconData icon;
  final int items;
  final double height, radius;
  final Color accentColor, baseColor, fillColor;

  @override
  State<NotifyBadge> createState() => _NotifyBadgeState();
}

class _NotifyBadgeState extends State<NotifyBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.height;
    return SizedBox(
      height: s,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              final pulse = 1 + 0.12 * math.sin(_c.value * 2 * math.pi);
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: s,
                    height: s,
                    decoration: BoxDecoration(
                      color: widget.fillColor,
                      borderRadius: BorderRadius.circular(widget.radius),
                    ),
                    child: Icon(widget.icon,
                        color: widget.baseColor, size: s * 0.5),
                  ),
                  Positioned(
                    top: -6,
                    left: -6,
                    child: Transform.scale(
                      scale: pulse,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        constraints: BoxConstraints(minWidth: s * 0.5),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: widget.accentColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: widget.accentColor.withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Text(
                          '${widget.items}',
                          style: TextStyle(
                            color: widget.fillColor,
                            fontSize: s * 0.24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
