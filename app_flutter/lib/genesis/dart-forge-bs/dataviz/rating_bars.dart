// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "dataviz" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/dataviz-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
// חוק-5/6): אפס צבע-קבוע. תוכן Label/Value/Meta.
import 'package:flutter/material.dart';
import '../../dart-ui-bs/ds/ds_seam.dart';

// ignore_for_file: unused_element
class _Op {
  final int k;            // 0 rect · 1 circle · 2 line · 3 path · 4 text · 5 arc
  final List<double> a; final Color c; final bool f; final double sw; final String d;
  final List<Color>? g; final List<double>? gs; final List<double>? gv;  // גרדיאנט: צבעים · עצירות · וקטור-שבר
  final int anchor;       // עוגן-טקסט: 0 start · 1 middle · 2 end
  _Op(this.k, this.a, this.c, this.f, this.sw, this.d, {this.g, this.gs, this.gv, this.anchor = 0, this.font = ''});
  static _Op rect(double x, double y, double w, double h, double r, Color c, bool f, double sw, {List<Color>? g, List<double>? gs, List<double>? gv}) => _Op(0, [x, y, w, h, r], c, f, sw, '', g: g, gs: gs, gv: gv);
  static _Op circle(double x, double y, double r, Color c, bool f, double sw) => _Op(1, [x, y, r], c, f, sw, '');
  static _Op line(double x1, double y1, double x2, double y2, Color c, double sw) => _Op(2, [x1, y1, x2, y2], c, false, sw, '');
  static _Op path(String d, Color c, bool f, double sw, {List<Color>? g, List<double>? gs, List<double>? gv}) => _Op(3, const [], c, f, sw, d, g: g, gs: gs, gv: gv);
  final String font;
  static _Op text(String s, double x, double y, double size, Color c, int anchor, String font) => _Op(4, [x, y, size], c, true, 0, s, anchor: anchor, font: font);
  static _Op arc(double cx, double cy, double r, double start, double sweep, Color c, double sw, {List<Color>? g, List<double>? gs, List<double>? gv}) => _Op(5, [cx, cy, r, start, sweep], c, false, sw, '', g: g, gs: gs, gv: gv);
}
class _SvgScene extends CustomPainter {
  final List<_Op> ops; final double vbw, vbh;
  const _SvgScene(this.ops, this.vbw, this.vbh);
  Alignment _al(double fx, double fy) => Alignment(fx * 2 - 1, fy * 2 - 1);
  Path? _safe(String d) { try { return _parse(d); } catch (_) { return null; } }
  void _paintText(Canvas cv, _Op o) {
    final tp = TextPainter(text: TextSpan(text: o.d, style: TextStyle(color: o.c, fontSize: o.a[2], fontFamily: o.font.isEmpty ? null : o.font, fontWeight: FontWeight.w600, fontFeatures: const [FontFeature.tabularFigures()])), textDirection: TextDirection.ltr)..layout();
    double dx = o.a[0]; if (o.anchor == 1) dx -= tp.width / 2; else if (o.anchor == 2) dx -= tp.width;
    tp.paint(cv, Offset(dx, o.a[1] - tp.height * 0.82));
  }
  @override
  void paint(Canvas cv, Size s) {
    if (vbw <= 0 || vbh <= 0) return;
    cv.save(); cv.scale(s.width / vbw, s.height / vbh);
    for (final o in ops) {
      if (o.k == 4) { _paintText(cv, o); continue; }
      final p = Paint()..style = o.f ? PaintingStyle.fill : PaintingStyle.stroke..strokeWidth = o.sw..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
      Rect b = Rect.zero; Path? pa;
      switch (o.k) {
        case 0: b = Rect.fromLTWH(o.a[0], o.a[1], o.a[2], o.a[3]); break;
        case 5: b = Rect.fromCircle(center: Offset(o.a[0], o.a[1]), radius: o.a[2]); break;
        case 3: pa = _safe(o.d); if (pa != null) b = pa.getBounds(); break;
      }
      if (o.g != null && o.g!.isNotEmpty) { final v = o.gv ?? const [0, 0, 0, 1]; p.shader = LinearGradient(begin: _al(v[0], v[1]), end: _al(v[2], v[3]), colors: o.g!, stops: o.gs).createShader(b.isEmpty ? const Rect.fromLTWH(0, 0, 1, 1) : b); }
      else { p.color = o.c; }
      switch (o.k) {
        case 0: cv.drawRRect(RRect.fromRectAndRadius(b, Radius.circular(o.a[4])), p); break;
        case 1: cv.drawCircle(Offset(o.a[0], o.a[1]), o.a[2], p); break;
        case 2: cv.drawLine(Offset(o.a[0], o.a[1]), Offset(o.a[2], o.a[3]), p); break;
        case 3: if (pa != null) cv.drawPath(pa, p); break;
        case 5: cv.drawArc(Rect.fromCircle(center: Offset(o.a[0], o.a[1]), radius: o.a[2]), o.a[3], o.a[4], false, p); break;
      }
    }
    cv.restore();
  }
  @override
  bool shouldRepaint(_SvgScene o) => true;
}
Path _parse(String d) {
  final path = Path();
  final t = RegExp(r'[a-zA-Z]|-?\d*\.?\d+(?:e-?\d+)?').allMatches(d).map((x) => x.group(0)!).toList();
  double cx = 0, cy = 0, sx = 0, sy = 0; String cmd = ''; int i = 0;
  double n() => double.parse(t[i++]);
  // דגל-קשת (largeArc/sweep) = ספרה-בודדת 0/1 · ה-SVG מתיר צמידות ("00-3-3") ⇒ הטוקנייזר מיזג ל"00";
  // קולפים תו-אחד ומשאירים את השארית לטוקן הבא (בלי זה קשת-מעוגלת בעיפרון/אייקון נשברת ⇒ אייקון-ריק).
  double fl() { final tok = t[i]; if (tok.length <= 1) { i++; return double.parse(tok); } t[i] = tok.substring(1); return double.parse(tok[0]); }
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
      case 'A': { double rx = n(), ry = n(), rot = n(), laf = fl(), sf = fl(), x = n(), y = n(); if (rel) { x += cx; y += cy; } path.arcToPoint(Offset(x, y), radius: Radius.elliptical(rx, ry), rotation: rot, largeArc: laf != 0, clockwise: sf != 0); cx = x; cy = y; break; }
      case 'Z': path.close(); cx = sx; cy = sy; break;
      default: if (i < t.length) i++;
    }
  }
  return path;
}

/// RatingBars — seam:fields
class ForgeRatingBars extends StatelessWidget {
  const ForgeRatingBars({super.key});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    return Container(constraints: const BoxConstraints(minHeight: 150), padding: const EdgeInsets.fromLTRB(16, 16, 16, 13), decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(16)), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, spacing: 11, children: [Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, spacing: 10, children: [Text("Label", style: TextStyle(color: skin.mut, fontFamily: fonts.he, fontSize: 12, fontWeight: FontWeight.w600)), Directionality(textDirection: TextDirection.ltr, child: Text("248", style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.44, height: 1, leadingDistribution: TextLeadingDistribution.even)))]), LayoutBuilder(builder: (ctx, cns) { final _w = cns.maxWidth.isFinite ? cns.maxWidth : 240.0; return SizedBox(width: _w, height: _w / 2.5000, child: CustomPaint(painter: _SvgScene([_Op.line(52, 6, 52, 86, skin.hair, 1), _Op.rect(52, 8, 120, 14, 3, theme.a.withValues(alpha: 0.260), true, 1.8), _Op.text("120", 178, 19, 9.5, skin.mut, 0, fonts.grotesk), _Op.text("A", 46, 19, 9, skin.faint, 2, fonts.grotesk), _Op.rect(52, 30, 86, 14, 3, theme.a.withValues(alpha: 0.260), true, 1.8), _Op.text("86", 144, 41, 9.5, skin.mut, 0, fonts.grotesk), _Op.text("B", 46, 41, 9, skin.faint, 2, fonts.grotesk), _Op.rect(52, 52, 164, 14, 3, skin.ink, true, 1.8, g: [theme.aHi, theme.a], gs: [0.00, 1.00], gv: [0.00, 0.00, 0.00, 1.00]), _Op.text("164", 222, 63, 9.5, skin.mut, 0, fonts.grotesk), _Op.text("C", 46, 63, 9, skin.faint, 2, fonts.grotesk), _Op.rect(52, 74, 64, 14, 3, theme.a.withValues(alpha: 0.260), true, 1.8), _Op.text("64", 122, 85, 9.5, skin.mut, 0, fonts.grotesk), _Op.text("D", 46, 85, 9, skin.faint, 2, fonts.grotesk)], 240, 96))); })]));
  }
}
