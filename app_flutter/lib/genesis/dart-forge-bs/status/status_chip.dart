// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "status" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/status-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta. material בלבד.
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

/// StatusChip — seam:series
class ForgeStatusChip extends StatelessWidget {
  const ForgeStatusChip({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(padding: const EdgeInsets.fromLTRB(2, 8, 2, 8), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 10, children: [Container(constraints: const BoxConstraints(minHeight: 26), padding: const EdgeInsets.fromLTRB(11, 5, 11, 5), decoration: BoxDecoration(borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 6, children: [Container(width: 6, height: 6, decoration: BoxDecoration(borderRadius: BorderRadius.circular(50))), Text("Label · info", style: TextStyle(color: skin.ink, fontFamily: fonts.he))])), Container(constraints: const BoxConstraints(minHeight: 26), padding: const EdgeInsets.fromLTRB(11, 5, 11, 5), decoration: BoxDecoration(borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 6, children: [CustomPaint(size: const Size(16, 16), painter: _SvgPaint("M5 13l4 4L19 7", skin.mut, 1.8, false, 24)), Text("Label · success", style: TextStyle(color: skin.ink, fontFamily: fonts.he))])), Container(constraints: const BoxConstraints(minHeight: 26), padding: const EdgeInsets.fromLTRB(11, 5, 11, 5), decoration: BoxDecoration(borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 6, children: [CustomPaint(size: const Size(16, 16), painter: _SvgPaint("M12 9v4M12 17h.01M10.3 4.3 2.6 18a2 2 0 0 0 1.7 3h15.4a2 2 0 0 0 1.7-3L13.7 4.3a2 2 0 0 0-3.4 0Z", skin.mut, 1.8, false, 24)), Text("Label · warning", style: TextStyle(color: skin.ink, fontFamily: fonts.he))])), Container(constraints: const BoxConstraints(minHeight: 26), padding: const EdgeInsets.fromLTRB(11, 5, 11, 5), decoration: BoxDecoration(borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 6, children: [CustomPaint(size: const Size(16, 16), painter: _SvgPaint("M12 8v5M12 17h.01 M 3 12 a 9 9 0 1 0 18 0 a 9 9 0 1 0 -18 0", skin.mut, 1.8, false, 24)), Text("Label · error", style: TextStyle(color: skin.ink, fontFamily: fonts.he))])), Container(constraints: const BoxConstraints(minHeight: 26), padding: const EdgeInsets.fromLTRB(11, 5, 11, 5), decoration: BoxDecoration(borderRadius: BorderRadius.circular(999)), child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 6, children: [Container(width: 6, height: 6, decoration: BoxDecoration(borderRadius: BorderRadius.circular(50))), Text("Label · neutral", style: TextStyle(color: skin.ink, fontFamily: fonts.he))]))]));
  }
}
