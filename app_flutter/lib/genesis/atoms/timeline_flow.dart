// 🎨 חוט-תצוגה · Timeline — ציר-זמן אנכי שנכנס מדורג (חוק-1/חוק-5).
// המנוע: N אירועים (נקודה + קו-מחבר + פס-תוכן) מחליקים פנימה בזה-אחר-זה (Interval).
// אפס-דאטה — גובה-שורה · מספר-אירועים · צבע-נקודה/טקסט/רקע מוזרקים בחיווט.
import 'package:flutter/material.dart';

class Timeline extends StatefulWidget {
  const Timeline({
    required this.height,
    required this.events,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    super.key,
  });
  final double height;
  final int events;
  final double radius;
  final Color accentColor, baseColor, fillColor;
  @override
  State<Timeline> createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final n = widget.events < 1 ? 1 : widget.events;
    return Column(
      children: List.generate(n, (i) {
        final start = (i / n) * 0.6;
        final anim = CurvedAnimation(parent: _c, curve: Interval(start, (start + 0.4).clamp(0.0, 1.0), curve: Curves.easeOut));
        return FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0.12, 0), end: Offset.zero).animate(anim),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: [
                      Container(width: 14, height: 14,
                          decoration: BoxDecoration(color: widget.accentColor, shape: BoxShape.circle)),
                      if (i < n - 1)
                        Expanded(child: Container(width: 2, color: widget.accentColor.withValues(alpha: 0.3))),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Container(
                      height: widget.height,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(color: widget.fillColor, borderRadius: BorderRadius.circular(widget.radius)),
                      child: Container(
                        height: 8, width: double.infinity,
                        decoration: BoxDecoration(
                          color: widget.baseColor.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(8),
                        ),
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
