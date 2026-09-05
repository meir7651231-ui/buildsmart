// 🔨 אטום-Dart מחושל (forge) · משפחת-Pure "composite" · מחולל ע"י machtzev/ds-forge.mjs ממקור-האמת
// machtzev/pure/composite-family.html (אל תערוך ידנית — regen). לובש עיצוב מהחריץ בלבד (DsSeam.skinOf/of/fontsOf,
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

/// SummaryCard — seam:fields · 10 חריצים
class ForgeSummaryCard extends StatelessWidget {
  /// תפר-דאטה (G12a): 10 חריצי-טקסט. null ⇒ תוכן-העיצוב (כמו ב-Pure); רשימה ⇒ fields[i] או '' — אין תוכן-דמו בייצור (§20-ג)
  final List<String>? fields;
  static const int fieldSlots = 10;
  static const List<String> fieldDemo = <String>["Label", "Meta", "Label", "248", "Label", "1,024", "Label", "92%", "Label", "340"];   // תוכן-העיצוב פר-חריץ — מלמד את המחולל את צורת-החריץ (מספר/טקסט), לא ערך
  String _f(int i, String d) => fields == null ? d : (i < fields!.length ? fields![i] : '');
  /// G13a · תוכן-נוסף בתוך מסגרת-האטום, אחרי זרימת-העיצוב (מקטע/כרטיס ⇒ תוכן-המודול). null ⇒ האטום לבדו.
  final Widget? child;
  // G13a · תוכן-נוסף בתוך המסגרת; null ⇒ ביט-זהה. גובה-חסום (Expanded/SizedBox סביב המסגרת) ⇒ התוכן ממלא (Expanded — רשימות/גלילה חיות, כמו GlassCard(child) של הזהב); גובה-חופשי ⇒ Column מכווץ-לתוכן.
  static Widget _withChild(Widget w, Widget? c) => c == null ? w : LayoutBuilder(builder: (ctx, cns) => cns.hasBoundedHeight
      ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, Expanded(child: c)])
      : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [w, c]));
  /// G13a · קבוצת-פריטים: items[i] = חריצי-הטקסט של פריט i (2 חריצים · 4 בדמו). null ⇒ פריטי-העיצוב.
  final List<List<String>>? items;
  static const int itemSlots = 2;
  static const int itemDemo = 4;
  String _it(List<String> r, int j, String d) => items == null ? d : (j < r.length ? r[j] : '');
  const ForgeSummaryCard({super.key, this.fields, this.child, this.items});
  @override
  Widget build(BuildContext context) {
    final skin = DsSeam.skinOf(context);   // מלוא-העיצוב מהחריץ
    final theme = DsSeam.of(context);       // אקצנט (מורף)
    final fonts = DsSeam.fontsOf(context);  // פונט
    final Widget body = Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [skin.surface, skin.sunken], begin: Alignment.topCenter, end: Alignment.bottomCenter), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(18)), child: _withChild(Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.fromLTRB(18, 16, 18, 14), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: skin.hair, width: 1))), child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, spacing: 12, children: [Container(width: 38, height: 38, alignment: Alignment.center, decoration: BoxDecoration(gradient: RadialGradient(center: Alignment(-0.40, -0.60), radius: 1.20, colors: [theme.gl, skin.sunken], stops: [0.0, 0.60]), border: Border.all(color: skin.hair), borderRadius: BorderRadius.circular(11)), child: SizedBox(width: 19, height: 19, child: CustomPaint(painter: _SvgScene([_Op.path("M3 3v18h18M7 15l4-4 3 3 5-6", theme.aHi, false, 1.8)], 24, 24)))), Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_f(0, "Label"), style: TextStyle(color: skin.ink, fontSize: 14, fontWeight: FontWeight.w600, fontFamily: fonts.he)), Directionality(textDirection: TextDirection.ltr, child: Text(_f(1, "Meta"), style: TextStyle(color: skin.faint, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 11)))]))])), Container(padding: const EdgeInsets.fromLTRB(18, 18, 18, 18), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [...(items == null ? <Widget>[Container(padding: const EdgeInsets.fromLTRB(0, 9, 0, 9), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: skin.hair2, width: 1))), child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [Flexible(child: Text(_f(2, "Label"), style: TextStyle(color: skin.mut, fontSize: 12.5, fontFamily: fonts.he), overflow: TextOverflow.ellipsis, softWrap: false)), Flexible(child: Directionality(textDirection: TextDirection.ltr, child: Text(_f(3, "248"), style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 12.5), overflow: TextOverflow.ellipsis, softWrap: false)))])), Container(padding: const EdgeInsets.fromLTRB(0, 9, 0, 9), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: skin.hair2, width: 1))), child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [Flexible(child: Text(_f(4, "Label"), style: TextStyle(color: skin.mut, fontSize: 12.5, fontFamily: fonts.he), overflow: TextOverflow.ellipsis, softWrap: false)), Flexible(child: Directionality(textDirection: TextDirection.ltr, child: Text(_f(5, "1,024"), style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 12.5), overflow: TextOverflow.ellipsis, softWrap: false)))])), Container(padding: const EdgeInsets.fromLTRB(0, 9, 0, 9), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: skin.hair2, width: 1))), child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [Flexible(child: Text(_f(6, "Label"), style: TextStyle(color: skin.mut, fontSize: 12.5, fontFamily: fonts.he), overflow: TextOverflow.ellipsis, softWrap: false)), Flexible(child: Directionality(textDirection: TextDirection.ltr, child: Text(_f(7, "92%"), style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 12.5), overflow: TextOverflow.ellipsis, softWrap: false)))])), Container(padding: const EdgeInsets.fromLTRB(0, 9, 0, 9), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: skin.hair2, width: 1))), child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [Flexible(child: Text(_f(8, "Label"), style: TextStyle(color: skin.mut, fontSize: 12.5, fontFamily: fonts.he), overflow: TextOverflow.ellipsis, softWrap: false)), Flexible(child: Directionality(textDirection: TextDirection.ltr, child: Text(_f(9, "340"), style: TextStyle(color: theme.aHi, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 12.5, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis, softWrap: false)))]))] : List<Widget>.generate(items!.length, (i) => Container(padding: const EdgeInsets.fromLTRB(0, 9, 0, 9), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: skin.hair2, width: 1))), child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [Flexible(child: Text(_it(items![i], 0, "Label"), style: TextStyle(color: skin.mut, fontSize: 12.5, fontFamily: fonts.he), overflow: TextOverflow.ellipsis, softWrap: false)), Flexible(child: Directionality(textDirection: TextDirection.ltr, child: Text(_it(items![i], 1, "248"), style: TextStyle(color: skin.ink, fontFamily: fonts.grotesk, fontFamilyFallback: [fonts.he], fontSize: 12.5), overflow: TextOverflow.ellipsis, softWrap: false)))]))))]))]), child));
    return body;
  }
}
