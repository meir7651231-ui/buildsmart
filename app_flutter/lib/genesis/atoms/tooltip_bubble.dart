// 🎨 חוט-תצוגה · TooltipBubble — בועית-הסבר עם זנב שמרחפת (חוק-1/חוק-5).
// המנוע: בועה עם זנב-משולש שמרחפת מעלה-מטה עדין (AnimationController). אפס-דאטה —
// טקסט · גובה · צבע-בועה/טקסט/רקע מוזרקים בחיווט.
import 'dart:math' as math;
import 'package:flutter/material.dart';
class TooltipBubble extends StatefulWidget {
  const TooltipBubble({required this.text, required this.height, required this.radius,
    required this.accentColor, required this.baseColor, required this.fillColor, super.key});
  final String text; final double height, radius;
  final Color accentColor, baseColor, fillColor;
  @override State<TooltipBubble> createState() => _TooltipBubbleState();
}
class _TooltipBubbleState extends State<TooltipBubble> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Center(child: AnimatedBuilder(animation: _c,
    builder: (context, child) => Transform.translate(offset: Offset(0, math.sin(_c.value * math.pi) * -6), child: child),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: widget.accentColor, borderRadius: BorderRadius.circular(widget.radius)),
        child: Text(widget.text, style: TextStyle(color: widget.fillColor, fontSize: 14, fontWeight: FontWeight.w700))),
      CustomPaint(size: const Size(16, 8), painter: _TailPainter(widget.accentColor)),
    ])));
}
class _TailPainter extends CustomPainter {
  _TailPainter(this.color); final Color color;
  @override void paint(Canvas canvas, Size size) {
    final p = Path()..moveTo(0, 0)..lineTo(size.width, 0)..lineTo(size.width / 2, size.height)..close();
    canvas.drawPath(p, Paint()..color = color);
  }
  @override bool shouldRepaint(_TailPainter old) => old.color != color;
}
