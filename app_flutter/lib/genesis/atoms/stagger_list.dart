// 🎨 חוט-תצוגה · StaggerList — רשימה שנכנסת בגלים מדורגים (חוק-1/חוק-5).
// המנוע: N שורות מחליקות+מתמוססות פנימה בזו-אחר-זו (Interval פר-שורה). אפס-דאטה —
// מספר-שורות · גובה · צבע-שורה/מבטא/רקע מוזרקים; נכנס פעם-אחת בטעינה.
import 'package:flutter/material.dart';

class StaggerList extends StatefulWidget {
  const StaggerList({
    required this.height,
    required this.rows,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    super.key,
  });

  final int rows;
  final double height, radius;
  final Color accentColor, baseColor, fillColor;

  @override
  State<StaggerList> createState() => _StaggerListState();
}

class _StaggerListState extends State<StaggerList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.rows < 1 ? 1 : widget.rows;
    return Column(
      children: List.generate(n, (i) {
        final start = (i / n) * 0.6;
        final anim = CurvedAnimation(
          parent: _c,
          curve: Interval(start, (start + 0.4).clamp(0.0, 1.0),
              curve: Curves.easeOutCubic),
        );
        return FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.15, 0),
              end: Offset.zero,
            ).animate(anim),
            child: Container(
              height: widget.height,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: widget.fillColor,
                borderRadius: BorderRadius.circular(widget.radius),
                border: Border(
                  right: BorderSide(color: widget.accentColor, width: 3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: widget.accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: widget.baseColor.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
