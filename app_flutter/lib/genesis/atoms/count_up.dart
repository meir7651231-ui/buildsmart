// 🎨 חוט-תצוגה · CountUp — מונה שמטפס 0→יעד בכניסה (חוק-1/חוק-5).
// המנוע: הספרה עולה בעקומה מרוככת (AnimationController) + תווית. אפס-דאטה —
// תווית · גובה · יעד · צבע-מספר/טקסט/רקע מוזרקים בחיווט.
import 'package:flutter/material.dart';

class CountUp extends StatefulWidget {
  const CountUp({
    required this.label,
    required this.height,
    required this.target,
    required this.radius,
    required this.accentColor,
    required this.baseColor,
    required this.fillColor,
    super.key,
  });
  final String label;
  final double height;
  final int target;
  final double radius;
  final Color accentColor, baseColor, fillColor;
  @override
  State<CountUp> createState() => _CountUpState();
}

class _CountUpState extends State<CountUp> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..forward();
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Container(
        height: widget.height,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(color: widget.fillColor, borderRadius: BorderRadius.circular(widget.radius)),
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final v = (Curves.easeOutCubic.transform(_c.value) * widget.target).round();
            return Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('$v',
                    style: TextStyle(color: widget.accentColor, fontSize: widget.height * 0.5, fontWeight: FontWeight.w900)),
                const SizedBox(width: 10),
                Text(widget.label, style: TextStyle(color: widget.baseColor.withValues(alpha: 0.75), fontSize: 14)),
              ],
            );
          },
        ),
      );
}
