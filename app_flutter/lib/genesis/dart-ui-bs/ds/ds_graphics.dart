// ✨ מאגר-העיצוב · רקעים-גנרטיביים (Graphics) — **מחולל ע"י machtzev/ds-graphics.mjs.**
// אל תערוך ידנית. CustomPainter דטרמיניסטיים המושכים מהפלטה/הגרדיאנטים (דאטה, הכרעה 19).
// material בלבד; shouldRepaint=false (רקע-סטטי); height מוזרק.
import 'package:flutter/material.dart';
import 'ds.dart';
import 'ds_scale.dart';

// ── רקע-אורורה נושם — גרדיאנט-אורורה + הילות רכות ──
class AuroraBg extends StatelessWidget {
  const AuroraBg({this.height = 220, super.key});
  final double height;
  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(painter: _AuroraBgPainter()),
      );
}

class _AuroraBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = DsGradient.aurora.createShader(rect));
    for (var i = 0; i < 3; i++) {
      final c = Offset(size.width * (0.2 + i * 0.3), size.height * (0.3 + (i.isEven ? 0.1 : -0.1)));
      canvas.drawCircle(c, size.width * 0.22, Paint()..color = Colors.white.withValues(alpha: 0.06)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── רקע-מֶש — שלוש כתמי-גרדיאנט רדיאליים ──
class MeshBg extends StatelessWidget {
  const MeshBg({this.height = 220, super.key});
  final double height;
  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(painter: _MeshBgPainter()),
      );
}

class _MeshBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = DsTokens.bg);
    const cols = [DsTokens.accent, Color(0xFF6366F1), DsTokens.success];
    for (var i = 0; i < cols.length; i++) {
      final c = Offset(size.width * (0.25 + i * 0.28), size.height * (i.isEven ? 0.28 : 0.66));
      final r = size.width * 0.4;
      canvas.drawCircle(c, r, Paint()..shader = RadialGradient(colors: [cols[i].withValues(alpha: 0.22), cols[i].withValues(alpha: 0.0)]).createShader(Rect.fromCircle(center: c, radius: r)));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── רקע-גלים — פס-גל תחתון בגרדיאנט-מבטא ──
class WaveBg extends StatelessWidget {
  const WaveBg({this.height = 220, super.key});
  final double height;
  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(painter: _WaveBgPainter()),
      );
}

class _WaveBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final p = Path()..moveTo(0, size.height * 0.7);
    p.quadraticBezierTo(size.width * 0.25, size.height * 0.6, size.width * 0.5, size.height * 0.72);
    p.quadraticBezierTo(size.width * 0.75, size.height * 0.84, size.width, size.height * 0.7);
    p.lineTo(size.width, size.height);
    p.lineTo(0, size.height);
    p.close();
    canvas.drawPath(p, Paint()..shader = DsGradient.accent.createShader(rect));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── רקע-רשת-נקודות — נקודות עדינות בריווח-קבוע ──
class DotGridBg extends StatelessWidget {
  const DotGridBg({this.height = 220, super.key});
  final double height;
  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(painter: _DotGridBgPainter()),
      );
}

class _DotGridBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = DsTokens.bg);
    final dot = Paint()..color = DsTokens.line;
    const gap = 24.0;
    for (var x = gap; x < size.width; x += gap) {
      for (var y = gap; y < size.height; y += gap) {
        canvas.drawCircle(Offset(x, y), 1.4, dot);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── רקע-זוהר — הילת-מבטא רדיאלית יחידה מלמעלה ──
class GlowBg extends StatelessWidget {
  const GlowBg({this.height = 220, super.key});
  final double height;
  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(painter: _GlowBgPainter()),
      );
}

class _GlowBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = DsTokens.bg);
    final c = Offset(size.width * 0.5, size.height * 0.1);
    final r = size.width * 0.7;
    canvas.drawCircle(c, r, Paint()..shader = RadialGradient(colors: [DsTokens.accent.withValues(alpha: 0.18), DsTokens.accent.withValues(alpha: 0.0)]).createShader(Rect.fromCircle(center: c, radius: r)));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
