// 🎨 חוט-תצוגה · RatingBars — פס-פילוח אופקי שנמתח בכניסה (חוק-1/חוק-5).
// המנוע: N שורות; רוחב-המילוי דטרמיניסטי (seed) נמתח 0→יעד (AnimationController).
// אפס-דאטה — גובה-שורה · מספר-שורות · צבע-מילוי/מסלול/רקע · seed מוזרקים בחיווט.
import 'dart:math' as math;
import 'package:flutter/material.dart';

class RatingBars extends StatefulWidget {
  const RatingBars({
    required this.height,
    required this.bars,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    this.seed = 0,
    super.key,
  });
  final double height;
  final int bars;
  final double radius;
  final Color accentColor, baseColor, fillColor;
  final int seed;
  @override
  State<RatingBars> createState() => _RatingBarsState();
}

class _RatingBarsState extends State<RatingBars> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..forward();
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final n = widget.bars < 1 ? 1 : widget.bars;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = Curves.easeOut.transform(_c.value);
        return Column(
          children: List.generate(n, (i) {
            final target = math.sin(i * 1.4 + widget.seed) * 0.4 + 0.55;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(width: 22, child: Text('${n - i}',
                      style: TextStyle(color: widget.baseColor.withValues(alpha: 0.7), fontSize: 13, fontWeight: FontWeight.w700))),
                  Expanded(
                    child: SizedBox(
                      height: widget.height.clamp(6.0, 18.0),
                      child: Stack(children: [
                        Container(decoration: BoxDecoration(color: widget.fillColor, borderRadius: BorderRadius.circular(20))),
                        FractionallySizedBox(
                          widthFactor: (target * t).clamp(0.0, 1.0),
                          child: Container(decoration: BoxDecoration(
                            color: Color.lerp(widget.baseColor, widget.accentColor, target),
                            borderRadius: BorderRadius.circular(20),
                          )),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}
