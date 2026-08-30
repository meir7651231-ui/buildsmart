// 🎨 חוט-תצוגה · DotsLoader — שלוש נקודות קופצות בתור (חוק-1/חוק-5).
// המנוע: שלוש נקודות שקופצות בהיסט-פאזה (AnimationController + Interval). אפס-דאטה —
// גובה · צבע-נקודה/רקע מוזרקים בחיווט.
import 'dart:math' as math;
import 'package:flutter/material.dart';

class DotsLoader extends StatefulWidget {
  const DotsLoader({
    required this.height,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    super.key,
  });

  final double height, radius;
  final Color accentColor, baseColor;

  @override
  State<DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<DotsLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = (widget.height * 0.28).clamp(6.0, 22.0);
    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final phase = (_c.value + i * 0.18) % 1;
            final lift = math.sin(phase * math.pi).clamp(0.0, 1.0);
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: d * 0.35),
              child: Transform.translate(
                offset: Offset(0, -lift * d),
                child: Container(
                  width: d,
                  height: d,
                  decoration: BoxDecoration(
                    color: Color.lerp(widget.baseColor, widget.accentColor, lift),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
