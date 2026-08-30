// 🎨 חוט-תצוגה · GradientText — כיתוב עם ריצוד-גרדיאנט נע (חוק-1/חוק-5).
// המנוע: ShaderMask עם גרדיאנט-סוויפ שמסתובב על הטקסט (AnimationController).
// אפס-דאטה — טקסט · גובה · שלושה גווני-גרדיאנט/רקע מוזרקים בחיווט.
import 'dart:math' as math;
import 'package:flutter/material.dart';

class GradientText extends StatefulWidget {
  const GradientText({
    required this.text,
    required this.height,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    super.key,
  });
  final String text;
  final double height, radius;
  final Color accentColor, baseColor, fillColor;
  @override
  State<GradientText> createState() => _GradientTextState();
}

class _GradientTextState extends State<GradientText> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Container(
        height: widget.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: widget.fillColor, borderRadius: BorderRadius.circular(widget.radius)),
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => ShaderMask(
            shaderCallback: (rect) => SweepGradient(
              transform: GradientRotation(_c.value * 2 * math.pi),
              colors: [widget.accentColor, widget.baseColor, widget.accentColor],
            ).createShader(rect),
            child: Text(
              widget.text,
              style: TextStyle(color: Colors.white, fontSize: widget.height * 0.42, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      );
}
