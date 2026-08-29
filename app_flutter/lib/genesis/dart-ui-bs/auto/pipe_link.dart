// 🧽 לוטש ע"י מנוע-המטרות (data-lift v3) — דאטה/מודל/תבנית הורמו ל-props לפי מטרתם, אל תערוך ידנית.
// מוצא: screens__install_studio_screen:_PipeLink (בנייה-חכמה main) · צרור-3 · props-שורש: label, label2
// התוכן: new/dart-data-bs/auto/screens__install_studio_screen_content.dart
import 'package:flutter/material.dart';
import 'bs_tokens.dart';
import 'dart:math' as math;

class PipeLink extends StatelessWidget {
  PipeLink(
      {required this.label, required this.label2, required this.from,
      required this.to,
      required this.flow,
      required this.broken});
  final String label;
  final String label2;
  final Color from;
  final Color to;
  final double flow;
  final bool broken;
  @override
  Widget build(BuildContext context) {
    final c = broken ? BsTokens.danger : _accent;
    return SizedBox(
      height: 30,
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
          width: 4, height: 30,
          child: CustomPaint(
            painter: _PipePainter(broken ? c : from, broken ? c : to, flow),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
              color: c.withOpacity(0.14),
              borderRadius: BorderRadius.circular(8)),
          child: Text(
              broken ? label : label2,
              style: TextStyle(
                  color: c, fontSize: 10, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}

const _accent = BsTokens.brand;

class _PipePainter extends CustomPainter {
  _PipePainter(this.from, this.to, this.flow);
  final Color from, to;
  final double flow;
  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width / 2;
    final track = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x, 0), Offset(x, size.height), track);
    // flowing pulse travelling down the pipe
    final t = (flow * 1.0) % 1.0;
    final y = t * size.height;
    final glow = Paint()
      ..shader = LinearGradient(colors: [from, to])
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawLine(
        Offset(x, math.max(0, y - 8)), Offset(x, math.min(size.height, y + 8)),
        glow);
  }

  @override
  bool shouldRepaint(_PipePainter old) => old.flow != flow;
}
