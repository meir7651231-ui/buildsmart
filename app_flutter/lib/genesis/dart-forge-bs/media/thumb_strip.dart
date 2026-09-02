// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "media" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/media-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

class _SvgPaint extends CustomPainter {
  final String d; final Color color; final double sw; final bool filled; final double vb;
  const _SvgPaint(this.d, this.color, this.sw, this.filled, this.vb);
  @override
  void paint(Canvas canvas, Size size) {
    Path raw;
    try { raw = _parse(d); } catch (_) { return; }   // path פגום ⇒ ריקון-רך, לא זריקה
    final m = Matrix4.identity()..scale(size.width / vb, size.height / vb);
    final p = raw.transform(m.storage);
    canvas.drawPath(p, Paint()
      ..color = color
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);
  }
  @override
  bool shouldRepaint(_SvgPaint o) => o.d != d || o.color != color || o.sw != sw || o.filled != filled;
}
Path _parse(String d) {
  final path = Path();
  final t = RegExp(r'[a-zA-Z]|-?\d*\.?\d+(?:e-?\d+)?').allMatches(d).map((x) => x.group(0)!).toList();
  double cx = 0, cy = 0, sx = 0, sy = 0; String cmd = ''; int i = 0;
  double n() => double.parse(t[i++]);
  while (i < t.length) {
    if (RegExp(r'[a-zA-Z]').hasMatch(t[i])) { cmd = t[i]; i++; }
    if (i > t.length) break;
    final rel = cmd == cmd.toLowerCase(); final C = cmd.toUpperCase();
    switch (C) {
      case 'M': { double x = n(), y = n(); if (rel) { x += cx; y += cy; } path.moveTo(x, y); cx = x; cy = y; sx = x; sy = y; cmd = rel ? 'l' : 'L'; break; }
      case 'L': { double x = n(), y = n(); if (rel) { x += cx; y += cy; } path.lineTo(x, y); cx = x; cy = y; break; }
      case 'H': { double x = n(); if (rel) x += cx; path.lineTo(x, cy); cx = x; break; }
      case 'V': { double y = n(); if (rel) y += cy; path.lineTo(cx, y); cy = y; break; }
      case 'C': { double x1 = n(), y1 = n(), x2 = n(), y2 = n(), x = n(), y = n(); if (rel) { x1 += cx; y1 += cy; x2 += cx; y2 += cy; x += cx; y += cy; } path.cubicTo(x1, y1, x2, y2, x, y); cx = x; cy = y; break; }
      case 'Q': { double x1 = n(), y1 = n(), x = n(), y = n(); if (rel) { x1 += cx; y1 += cy; x += cx; y += cy; } path.quadraticBezierTo(x1, y1, x, y); cx = x; cy = y; break; }
      case 'A': { double rx = n(), ry = n(), rot = n(), laf = n(), sf = n(), x = n(), y = n(); if (rel) { x += cx; y += cy; } path.arcToPoint(Offset(x, y), radius: Radius.elliptical(rx, ry), rotation: rot, largeArc: laf != 0, clockwise: sf != 0); cx = x; cy = y; break; }
      case 'Z': path.close(); cx = sx; cy = sy; break;
      default: if (i < t.length) i++;
    }
  }
  return path;
}

/// ThumbStrip — seam:collection
class ForgeThumbStrip extends StatelessWidget {
  const ForgeThumbStrip({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    return Container(padding: const EdgeInsets.fromLTRB(2, 2, 2, 2), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 8, children: [Container(width: 64, height: 64, decoration: BoxDecoration(color: theme.a, border: Border.all(color: theme.a, width: 2), borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: theme.gl, offset: const Offset(0, 0), blurRadius: 0, spreadRadius: 3)]), child: CustomPaint(size: const Size(16, 16), painter: _SvgPaint("M 3 4 h 18 v 16 h -18 Z M 6.9 9 a 1.6 1.6 0 1 0 3.2 0 a 1.6 1.6 0 1 0 -3.2 0 M4 18l5-5 3.5 3.5L16 13l4 4", skin.ink, 1.8, false, 24))), Container(width: 64, height: 64, decoration: BoxDecoration(color: theme.a, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(10)), child: CustomPaint(size: const Size(16, 16), painter: _SvgPaint("M 3 4 h 18 v 16 h -18 Z M 6.9 9 a 1.6 1.6 0 1 0 3.2 0 a 1.6 1.6 0 1 0 -3.2 0 M4 18l5-5 3.5 3.5L16 13l4 4", skin.ink, 1.8, false, 24))), Container(width: 64, height: 64, decoration: BoxDecoration(color: theme.a, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(10)), child: CustomPaint(size: const Size(16, 16), painter: _SvgPaint("M 3 4 h 18 v 16 h -18 Z M 6.9 9 a 1.6 1.6 0 1 0 3.2 0 a 1.6 1.6 0 1 0 -3.2 0 M4 18l5-5 3.5 3.5L16 13l4 4", skin.ink, 1.8, false, 24))), Container(width: 64, height: 64, decoration: BoxDecoration(color: theme.a, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(10)), child: CustomPaint(size: const Size(16, 16), painter: _SvgPaint("M 3 4 h 18 v 16 h -18 Z M 6.9 9 a 1.6 1.6 0 1 0 3.2 0 a 1.6 1.6 0 1 0 -3.2 0 M4 18l5-5 3.5 3.5L16 13l4 4", skin.ink, 1.8, false, 24))), Container(width: 64, height: 64, decoration: BoxDecoration(color: theme.a, border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(10)), child: CustomPaint(size: const Size(16, 16), painter: _SvgPaint("M 3 4 h 18 v 16 h -18 Z M 6.9 9 a 1.6 1.6 0 1 0 3.2 0 a 1.6 1.6 0 1 0 -3.2 0 M4 18l5-5 3.5 3.5L16 13l4 4", skin.ink, 1.8, false, 24)))]));
  }
}
