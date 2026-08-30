// 🎨 חוט-תצוגה · GanttBar — תרשים-גאנט שפסיו נמתחים בכניסה (חוק-1/חוק-5).
// המנוע: N שורות-משימה, כל פס בהיסט+אורך דטרמיניסטיים (seed) שנמתח 0→מלא (Interval).
// אפס-דאטה — גובה-שורה · מספר-שורות · צבע-פס/מבטא/רקע · seed מוזרקים בחיווט.
import 'dart:math' as math;
import 'package:flutter/material.dart';

class GanttBar extends StatefulWidget {
  const GanttBar({
    required this.height,
    required this.rows,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    this.seed = 0,
    super.key,
  });
  final double height;
  final int rows;
  final double radius;
  final Color accentColor, baseColor, fillColor;
  final int seed;
  @override
  State<GanttBar> createState() => _GanttBarState();
}

class _GanttBarState extends State<GanttBar> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final n = widget.rows < 1 ? 1 : widget.rows;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: widget.fillColor, borderRadius: BorderRadius.circular(widget.radius)),
      child: Column(
        children: List.generate(n, (i) {
          final start = (math.sin(i * 1.7 + widget.seed) * 0.5 + 0.5) * 0.4;
          final len = 0.25 + (math.cos(i * 1.3 + widget.seed) * 0.5 + 0.5) * 0.5;
          final anim = CurvedAnimation(parent: _c, curve: Interval((i / n) * 0.5, 1, curve: Curves.easeOut));
          return Padding(
            padding: EdgeInsets.symmetric(vertical: widget.height * 0.14),
            child: SizedBox(
              height: widget.height.clamp(8.0, 20.0),
              child: LayoutBuilder(
                builder: (context, c) => Stack(children: [
                  Container(decoration: BoxDecoration(color: widget.baseColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6))),
                  AnimatedBuilder(
                    animation: anim,
                    builder: (context, _) => Positioned(
                      left: c.maxWidth * start,
                      child: Container(
                        width: c.maxWidth * len * anim.value,
                        height: widget.height.clamp(8.0, 20.0),
                        decoration: BoxDecoration(
                          color: Color.lerp(widget.baseColor, widget.accentColor, i / n),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          );
        }),
      ),
    );
  }
}
