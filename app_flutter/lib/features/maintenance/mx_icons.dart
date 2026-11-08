/// Maintenance module — the house icon set (design round 3).
///
/// One family, drawn for this product: 24-unit grid, 1.75 stroke (1.5 at
/// 20 dp), round caps and joins, outline only. Buildings, doors, the store
/// and rooms are built on the brand's doorway arch. Paths use a small SVG
/// path subset (M L H V C Q A Z, absolute + relative) parsed once.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A drawn icon (SVG path data on a 24 × 24 grid).
@immutable
class MxGlyph {
  const MxGlyph(this.d, {this.label = ''});
  final String d;
  final String label;
}

/// Renders an [MxGlyph] in the house stroke style.
class MxIcon extends StatelessWidget {
  const MxIcon(this.glyph, {this.size = 24, this.color, super.key});
  final MxGlyph glyph;
  final double size;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final c = color ?? IconTheme.of(context).color ?? Colors.black;
    final icon = CustomPaint(
      size: Size.square(size),
      painter: _GlyphPainter(glyph, c, size <= 20 ? 1.5 : 1.75),
    );
    return glyph.label.isEmpty
        ? ExcludeSemantics(child: icon)
        : Semantics(label: glyph.label, child: icon);
  }
}

/// Icon from either the house set ([MxGlyph]) or Material ([IconData]).
Widget mxIcon(Object g, {double size = 24, Color? color}) =>
    g is MxGlyph
        ? MxIcon(g, size: size, color: color)
        : Icon(g as IconData, size: size, color: color);

class _GlyphPainter extends CustomPainter {
  _GlyphPainter(this.glyph, this.color, this.stroke);
  final MxGlyph glyph;
  final Color color;
  final double stroke;

  static final Map<String, Path> _cache = {};

  @override
  void paint(Canvas canvas, Size size) {
    final path = _cache.putIfAbsent(glyph.d, () => mxParsePath(glyph.d));
    final s = size.width / 24;
    // The canvas is scaled to the 24-unit grid, so the stroke is divided
    // back to keep it [stroke] device-independent pixels wide.
    canvas
      ..save()
      ..scale(s)
      ..drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke / s
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.glyph != glyph || old.color != color || old.stroke != stroke;
}

/// Parse a subset of SVG path data into a [Path].
Path mxParsePath(String d) {
  final tokens =
      RegExp(
        r'[MmLlHhVvCcQqAaZz]|-?(?:\d+\.?\d*|\.\d+)(?:e-?\d+)?',
      ).allMatches(d).map((m) => m.group(0)!).toList();
  final p = Path();
  var i = 0;
  var cmd = 'M';
  var x = 0.0;
  var y = 0.0;
  var sx = 0.0;
  var sy = 0.0;
  bool isCmd(String t) => RegExp('^[A-Za-z]').hasMatch(t);
  double n() => double.parse(tokens[i++]);
  while (i < tokens.length) {
    if (isCmd(tokens[i])) cmd = tokens[i++];
    final rel = cmd == cmd.toLowerCase();
    switch (cmd.toUpperCase()) {
      case 'M':
        x = (rel ? x : 0) + n();
        y = (rel ? y : 0) + n();
        p.moveTo(x, y);
        sx = x;
        sy = y;
        cmd = rel ? 'l' : 'L'; // implicit lineto after a moveto
      case 'L':
        x = (rel ? x : 0) + n();
        y = (rel ? y : 0) + n();
        p.lineTo(x, y);
      case 'H':
        x = (rel ? x : 0) + n();
        p.lineTo(x, y);
      case 'V':
        y = (rel ? y : 0) + n();
        p.lineTo(x, y);
      case 'C':
        final x1 = (rel ? x : 0) + n();
        final y1 = (rel ? y : 0) + n();
        final x2 = (rel ? x : 0) + n();
        final y2 = (rel ? y : 0) + n();
        x = (rel ? x : 0) + n();
        y = (rel ? y : 0) + n();
        p.cubicTo(x1, y1, x2, y2, x, y);
      case 'Q':
        final x1 = (rel ? x : 0) + n();
        final y1 = (rel ? y : 0) + n();
        x = (rel ? x : 0) + n();
        y = (rel ? y : 0) + n();
        p.quadraticBezierTo(x1, y1, x, y);
      case 'A':
        final rx = n();
        final ry = n();
        final rot = n();
        final large = n() != 0;
        final sweep = n() != 0;
        x = (rel ? x : 0) + n();
        y = (rel ? y : 0) + n();
        p.arcToPoint(
          Offset(x, y),
          radius: Radius.elliptical(rx, ry),
          rotation: rot * math.pi / 180,
          largeArc: large,
          clockwise: sweep,
        );
      case 'Z':
        p.close();
        x = sx;
        y = sy;
      default:
        i++;
    }
  }
  return p;
}

// ── the set ──────────────────────────────────────────────────────────────────
// Rooms and buildings share the doorway arch: M x 21 V 10 a r r 0 0 1 … V 21.

abstract final class MxGlyphs {
  // navigation
  static const board = MxGlyph(
    'M4 4h7v7H4z M13 4h7v4h-7z M13 10h7v10h-7z M4 13h7v7H4z',
  );
  static const sites = MxGlyph(
    'M4 21V10a8 8 0 0 1 16 0v11 M2 21h20 M10 21v-5h4v5 M9 10h.01 M15 10h.01 M12 7h.01',
  );
  static const wrench = MxGlyph(
    'M15 4a4 4 0 0 0-4.6 5.2L4 15.6V20h4.4l6.4-6.4A4 4 0 0 0 20 9l-3 .5-2-2L15.5 4z',
  );
  static const calendarCheck = MxGlyph(
    'M4 6h16v15H4z M4 10h16 M8 3v4 M16 3v4 M9 15.5l2 2 4-4',
  );
  static const cart = MxGlyph(
    'M3 4h2l2.4 11h10.4l2.2-8H6.2 M9 20h.01 M17 20h.01',
  );
  static const megaphone = MxGlyph(
    'M4 10v4h3l7 4V6l-7 4z M17.5 9.5a3.5 3.5 0 0 1 0 5 M7 14l1 5h2',
  );
  static const list = MxGlyph(
    'M9 6h11 M9 12h11 M9 18h11 M4.5 6h.01 M4.5 12h.01 M4.5 18h.01',
  );
  static const store = MxGlyph(
    'M4 21V10a8 8 0 0 1 16 0v11 M2 21h20 M8 12h8 M10 21v-4h4v4',
  );
  // rooms
  static const kitchen = MxGlyph(
    'M4 11h16 M6 11v6a3 3 0 0 0 3 3h6a3 3 0 0 0 3-3v-6 M9 8c0-1.2 1-1.3 1-2.5 M14 8c0-1.2 1-1.3 1-2.5',
  );
  static const bath = MxGlyph(
    'M3 12h18 M5 12v3a4 4 0 0 0 4 4h6a4 4 0 0 0 4-4v-3 M6.5 12V6a2 2 0 0 1 3.7-1 M7 19l-1 2 M17 19l1 2',
  );
  static const bed = MxGlyph(
    'M3 19V7 M3 15h18v4 M21 15v-2a3 3 0 0 0-3-3h-7v5 M7 12.5h.01',
  );
  static const sofa = MxGlyph(
    'M5 11V8a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2v3 M3 13a2 2 0 0 1 4 0v2h10v-2a2 2 0 0 1 4 0v5H3z M5 18v2 M19 18v2',
  );
  static const laundry = MxGlyph(
    'M5 3h14v18H5z M5 7h14 M8 5h.01 M12 10a4 4 0 1 0 0 8a4 4 0 1 0 0-8 M10 14c1-1 3 1 4 0',
  );
  static const door = MxGlyph(
    'M6 21V9a6 6 0 0 1 12 0v12 M4 21h16 M14.5 14h.01',
  );
  static const shelter = MxGlyph(
    'M12 3l8 3v6c0 5-3.5 8-8 9-4.5-1-8-4-8-9V6z M9 12l2 2 4-4',
  );
  // points
  static const outlet = MxGlyph(
    'M6 3h12a3 3 0 0 1 3 3v12a3 3 0 0 1-3 3H6a3 3 0 0 1-3-3V6a3 3 0 0 1 3-3z M9.5 9v2.5 M14.5 9v2.5 M12 15v1.5',
  );
  static const lightSwitch = MxGlyph(
    'M6 3h12a3 3 0 0 1 3 3v12a3 3 0 0 1-3 3H6a3 3 0 0 1-3-3V6a3 3 0 0 1 3-3z M10 7h4v10h-4z M10 12h4',
  );
  static const bulb = MxGlyph(
    'M9 18h6 M10 21h4 M12 3a6 6 0 0 0-3.5 10.9c.7.5 1 1.3 1 2.1h5c0-.8.3-1.6 1-2.1A6 6 0 0 0 12 3z',
  );
  static const faucet = MxGlyph(
    'M3 14h7a2 2 0 0 0 2-2V8 M8 8h8 M12 5v3 M16 8h1a3 3 0 0 1 3 3v2 M20 17v.5',
  );
  static const drain = MxGlyph(
    'M4 12a8 8 0 1 0 16 0a8 8 0 1 0-16 0 M8.5 10h7 M8.5 14h7',
  );
  static const toilet = MxGlyph(
    'M6 3h6v7H6z M4 10h16a6 6 0 0 1-6 6h-4a6 6 0 0 1-6-6z M9 16l-1 5h8l-1-5',
  );
  static const shower = MxGlyph(
    'M4 21V8a4 4 0 0 1 8 0 M9 8h6 M10 12v1 M13 12v1 M16 12v1 M11.5 15.5v1 M14.5 15.5v1',
  );
  static const thermo = MxGlyph(
    'M10 4a2 2 0 0 1 4 0v10a4 4 0 1 1-4 0z M12 9v7',
  );
  static const grabBar = MxGlyph('M4 12h16 M6 9v6 M18 9v6');
  static const fan = MxGlyph(
    'M10 12a2 2 0 1 0 4 0a2 2 0 1 0-4 0 M12 10c0-4 4.5-6 5.5-3 M14 12c4 0 6 4.5 3 5.5 M12 14c0 4-4.5 6-5.5 3 M10 12c-4 0-6-4.5-3-5.5',
  );
  static const ac = MxGlyph(
    'M3 5h18v8H3z M7 10h10 M8 16l-1 3 M12 16v4 M16 16l1 3',
  );
  static const window = MxGlyph('M5 3h14v18H5z M12 3v18 M5 12h14');
  static const shutter = MxGlyph(
    'M3 4h18 M5 4v14h14V4 M5 8h14 M5 12h14 M12 18v3',
  );
  static const mezuzah = MxGlyph('M10 3h4v18h-4z M12 7v2 M10 17h4');
  static const boiler = MxGlyph(
    'M6 3h12v14H6z M9 17v4 M15 17v4 M9 8h6 M9 11h6',
  );
  static const clock = MxGlyph(
    'M3 12a9 9 0 1 0 18 0a9 9 0 1 0-18 0 M12 7v5l3 2',
  );
  static const breaker = MxGlyph(
    'M5 3h14v18H5z M9 7h6 M9 11h6 M12 14l-2 3h4l-2 3',
  );
  static const exitSensor = MxGlyph(
    'M6 21V9a6 6 0 0 1 12 0v12 M4 21h16 M20 8a3 3 0 0 0-3-3 M22 8a5 5 0 0 0-5-5',
  );
  static const smoke = MxGlyph(
    'M3 6h18v4H3z M6 10v1a6 3 0 0 0 12 0v-1 M12 15v1 M9 18l-.5 1 M15 18l.5 1',
  );
  static const extinguisher = MxGlyph(
    'M9 8h6v13H9z M12 8V5 M12 5h4 M16 5l2 2 M9 12h6',
  );
  static const lock = MxGlyph(
    'M6 11h12v10H6z M8 11V8a4 4 0 0 1 8 0v3 M12 15v2',
  );
  // status & actions
  static const warning = MxGlyph(
    'M12 3l9.5 17h-19z M12 9.5v4.5 M12 17h.01',
    label: 'אזהרה',
  );
  static const phone = MxGlyph(
    'M5 4h3l2 5-2.5 1.5a11 11 0 0 0 5 5L14 13l5 2v3a2 2 0 0 1-2 2A15 15 0 0 1 3 6a2 2 0 0 1 2-2z',
  );
  static const truck = MxGlyph(
    'M3 6h11v10H3z M14 9h4l3 3v4h-7 M7 18a2 2 0 1 0 0 .01 M17 18a2 2 0 1 0 0 .01',
  );
  static const check = MxGlyph('M5 12.5l4.5 4.5L19 7');
  static const legal = MxGlyph(
    'M6 3h9l3 3v15H6z M9 8h6 M9 11h6 M12 15a2 2 0 1 0 0 4a2 2 0 1 0 0-4',
  );
  static const box = MxGlyph(
    'M3 7l9-4 9 4v10l-9 4-9-4z M3 7l9 4 9-4 M12 11v10',
  );
  static const receipt = MxGlyph(
    'M6 3h12v18l-2-1.5-2 1.5-2-1.5-2 1.5-2-1.5L6 21z M9 8h6 M9 12h6 M9 16h3',
  );
}

/// The house glyph for a point type.
MxGlyph mxPointGlyph(String type) => switch (type) {
  'שקע' => MxGlyphs.outlet,
  'מתג' => MxGlyphs.lightSwitch,
  'גוף תאורה' || 'תאורת חירום' => MxGlyphs.bulb,
  'ברז' || 'ברז ניל' => MxGlyphs.faucet,
  'סיפון' || 'מחסום רצפה' => MxGlyphs.drain,
  'אסלה' => MxGlyphs.toilet,
  'סוללת מקלחת' => MxGlyphs.shower,
  'מגביל טמפרטורה' => MxGlyphs.thermo,
  'מאחז יד' => MxGlyphs.grabBar,
  'מאוורר' => MxGlyphs.fan,
  'מזגן' => MxGlyphs.ac,
  'מעצור חלון' => MxGlyphs.window,
  'תריס' => MxGlyphs.shutter,
  'מזוזה' => MxGlyphs.mezuzah,
  'דוד שמש' => MxGlyphs.boiler,
  'שעון שבת' => MxGlyphs.clock,
  'ממסר פחת' || 'מאמ"ת' => MxGlyphs.breaker,
  'חיישן יציאה' => MxGlyphs.exitSensor,
  'גלאי עשן' => MxGlyphs.smoke,
  'מטף' => MxGlyphs.extinguisher,
  'מנעול' => MxGlyphs.lock,
  _ => MxGlyphs.wrench,
};

/// The house glyph for a room.
MxGlyph mxRoomGlyph(String room) {
  if (room.contains('מטבח')) return MxGlyphs.kitchen;
  if (room.contains('רחצה')) return MxGlyphs.bath;
  if (room.contains('שינה')) return MxGlyphs.bed;
  if (room.contains('כביסה')) return MxGlyphs.laundry;
  if (room.contains('סלון')) return MxGlyphs.sofa;
  if (room.contains('ממ"ד') || room.contains('ממ״ד') || room.contains('מקלט')) {
    return MxGlyphs.shelter;
  }
  return MxGlyphs.door;
}
