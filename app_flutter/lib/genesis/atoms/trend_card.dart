// 🎨 חוט-תצוגה · TrendCard — כרטיס-מדד עם חץ-מגמה וסְפַּרְקְלַיְן (חוק-1/חוק-5).
// המנוע: ערך גדול + חץ-עלייה + קו-מיני שנמתח בכניסה (AnimationController). אפס-דאטה —
// ערך · תווית · גובה · צבע-מבטא/טקסט/רקע מוזרקים בחיווט.
import 'dart:math' as math;
import 'package:flutter/material.dart';
class TrendCard extends StatefulWidget {
  const TrendCard({required this.title, required this.sub, required this.height, required this.radius,
    required this.accentColor, required this.baseColor, required this.fillColor, super.key});
  final String title, sub; final double height, radius;
  final Color accentColor, baseColor, fillColor;
  @override State<TrendCard> createState() => _TrendCardState();
}
class _TrendCardState extends State<TrendCard> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Container(
    height: widget.height, padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: widget.fillColor, borderRadius: BorderRadius.circular(widget.radius * 1.3)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(widget.sub, style: TextStyle(color: widget.baseColor.withValues(alpha: 0.6), fontSize: 13)),
      const SizedBox(height: 6),
      Row(children: [
        Text(widget.title, style: TextStyle(color: widget.baseColor, fontSize: 26, fontWeight: FontWeight.w900)),
        const SizedBox(width: 8),
        Icon(Icons.trending_up, color: widget.accentColor, size: 20),
      ]),
      const Spacer(),
      Expanded(child: AnimatedBuilder(animation: _c, builder: (context, _) => CustomPaint(
        size: Size.infinite, painter: _MiniSpark(Curves.easeOut.transform(_c.value), widget.accentColor)))),
    ]));
}
class _MiniSpark extends CustomPainter {
  _MiniSpark(this.t, this.color); final double t; final Color color;
  @override void paint(Canvas canvas, Size size) {
    const n = 12; final drawn = (n * t).clamp(1, n).round();
    Offset at(int i) => Offset(size.width * i / (n - 1), size.height * (1 - (math.sin(i * 0.8) * 0.4 + 0.5)));
    final line = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < drawn; i++) line.lineTo(at(i).dx, at(i).dy);
    canvas.drawPath(line, Paint()..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round..color = color);
  }
  @override bool shouldRepaint(_MiniSpark old) => old.t != t;
}
