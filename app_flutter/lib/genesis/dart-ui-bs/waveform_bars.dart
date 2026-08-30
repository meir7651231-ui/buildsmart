// 🎨 חוט-תצוגה · WaveformBars — פסקול-אודיו פועם (חוק-1/חוק-5).
// המנוע: N פסים אנכיים שקופצים בגובה מחזורי בהיסט-פאזה (AnimationController).
// אפס-דאטה — גובה · מספר-פסים · צבע-פס/מבטא/רקע מוזרקים בחיווט.
import 'dart:math' as math;
import 'package:flutter/material.dart';

class WaveformBars extends StatefulWidget {
  const WaveformBars({
    required this.height,
    required this.bars,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    super.key,
  });
  final double height;
  final int bars;
  final double radius;
  final Color accentColor, baseColor, fillColor;
  @override
  State<WaveformBars> createState() => _WaveformBarsState();
}

class _WaveformBarsState extends State<WaveformBars> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final n = widget.bars < 1 ? 1 : widget.bars;
    return Container(
      height: widget.height,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: widget.fillColor, borderRadius: BorderRadius.circular(widget.radius)),
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(n, (i) {
            final h = (math.sin(_c.value * 2 * math.pi + i * 0.6) * 0.5 + 0.55).clamp(0.15, 1.0);
            return Container(
              width: (widget.height * 0.08).clamp(3.0, 8.0),
              height: widget.height * 0.7 * h,
              decoration: BoxDecoration(
                color: Color.lerp(widget.baseColor, widget.accentColor, h),
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }),
        ),
      ),
    );
  }
}
