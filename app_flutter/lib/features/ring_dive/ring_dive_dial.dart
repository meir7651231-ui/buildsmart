/// RingDive Pro-X-Light — the SVG-style dial, one [CustomPainter]. Faithful port
/// of the prototype's `<svg viewBox="-52 -52 444 444">` (center 170,170): a warm
/// radial PLATE, a 72-tick ring (major every 6), a top WEDGE focus-pointer,
/// dashed locked "chosen" rings, and the option labels on the r=122 ring — the
/// focused one enlarged/orange inside a halo, others muted, each with a white
/// stroke and an optional colour dot. The glassmorphic hub + qty dual-ring +
/// pizza slices are layered by the wheel/screen; this paints the plate + labels.
///
/// Coordinates are the prototype's SVG space (center 170,170); the painter maps
/// the 444-unit viewBox onto the widget's square via a scale+translate, so every
/// radius/angle matches the design 1:1.
library;

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';

/// Prototype SVG geometry (center 170,170; viewBox -52 -52 444 444).
class RingDiveGeo {
  const RingDiveGeo._();

  static const double viewBox = 444; // -52..392
  static const double cx = 170;
  static const double cy = 170;
  static const double plate = 150;
  static const double bezel = 164;
  static const double labelR = 122;
  static const int ticks = 72;
}

/// The dial. Sizes to a square; [rotation] in degrees (0 static).
class RingDiveDial extends StatelessWidget {
  const RingDiveDial({
    this.labels = const <String>[],
    this.dots = const <Color?>[],
    this.focus = 0,
    this.rotation = 0,
    this.lockedCount = 0,
    this.size = 340,
    super.key,
  });

  final List<String> labels;

  /// Optional colour swatch per option (parallel to [labels]); null = none.
  final List<Color?> dots;
  final int focus;
  final double rotation;
  final int lockedCount;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size.square(size),
        painter: _DialPainter(
          labels: labels,
          dots: dots,
          focus: focus,
          rotation: rotation,
          lockedCount: lockedCount,
        ),
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  _DialPainter({
    required this.labels,
    required this.dots,
    required this.focus,
    required this.rotation,
    required this.lockedCount,
  });

  final List<String> labels;
  final List<Color?> dots;
  final int focus;
  final double rotation;
  final int lockedCount;

  static const Offset _c = Offset(RingDiveGeo.cx, RingDiveGeo.cy);

  /// Per-label cache of the two [TextPainter]s (halo + fill) for the *unfocused*
  /// style. Only rotation/focus change between most frames, so the label content
  /// and its unfocused layout are stable — laying each out once and reusing it
  /// avoids 2× layouts per option per frame (144 on a 72-option wheel). Keyed by
  /// label text. Invalidation is by lifetime: a labels change makes
  /// [shouldRepaint] adopt a fresh painter (empty cache), while an unchanged
  /// wheel keeps this painter and reuses its entries. The one focused label
  /// restyles as the wheel turns, so it is built fresh each paint.
  final Map<String, (TextPainter, TextPainter)> _unfocusedCache =
      <String, (TextPainter, TextPainter)>{};

  double _rad(double deg) => deg * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    // Map the 444 viewBox (origin -52,-52) onto the square widget.
    final s = size.width / RingDiveGeo.viewBox;
    canvas
      ..save()
      ..scale(s)
      ..translate(52, 52);

    _paintBezelPlate(canvas);
    _paintTicks(canvas);
    _paintLockedRings(canvas);
    _paintWedge(canvas);
    _paintLabels(canvas);

    canvas.restore();
  }

  void _paintBezelPlate(Canvas canvas) {
    canvas
      ..drawCircle(
        _c,
        RingDiveGeo.bezel,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0x12000000),
      )
      ..drawCircle(
        _c,
        RingDiveGeo.plate,
        Paint()
          ..shader = ui.Gradient.radial(
            const Offset(RingDiveGeo.cx, RingDiveGeo.viewBox * 0 + 170 - 45),
            RingDiveGeo.plate * 1.0,
            const <Color>[
              Color(0xFFFFFFFF),
              Color(0xFFF6F1EA),
              Color(0xFFECE4D9),
            ],
            const <double>[0, 0.58, 1],
          ),
      )
      ..drawCircle(
        _c,
        RingDiveGeo.plate,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = const Color(0x0D000000),
      );
  }

  void _paintTicks(Canvas canvas) {
    const t = RingDiveGeo.ticks;
    for (var i = 0; i < t; i++) {
      final a = _rad(i / t * 360 - 90);
      final major = i % 6 == 0;
      final r1 = major ? 134.0 : 140.0;
      const r2 = 150.0;
      canvas.drawLine(
        Offset(_c.dx + r1 * math.cos(a), _c.dy + r1 * math.sin(a)),
        Offset(_c.dx + r2 * math.cos(a), _c.dy + r2 * math.sin(a)),
        Paint()
          ..strokeCap = StrokeCap.round
          ..strokeWidth = major ? 2 : 1
          ..color = major ? const Color(0x99FF7A18) : const Color(0x29463C32),
      );
    }
  }

  void _paintLockedRings(Canvas canvas) {
    for (var i = 0; i < lockedCount; i++) {
      final rr = 118.0 - i * 15.0;
      final recent = i == lockedCount - 1;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = recent ? 2 : 1.4
        ..color = recent ? const Color(0xB3FF7A18) : const Color(0x38FF7A18);
      if (recent) {
        canvas.drawCircle(_c, rr, paint);
      } else {
        _dashedCircle(canvas, rr, paint, dash: 3, gap: 6);
      }
    }
  }

  void _dashedCircle(
    Canvas canvas,
    double r,
    Paint paint, {
    required double dash,
    required double gap,
  }) {
    final circ = 2 * math.pi * r;
    final step = dash + gap;
    final count = (circ / step).floor();
    for (var i = 0; i < count; i++) {
      final a0 = i * step / r;
      final a1 = a0 + dash / r;
      canvas.drawArc(
        Rect.fromCircle(center: _c, radius: r),
        a0,
        a1 - a0,
        false,
        paint,
      );
    }
  }

  /// The top wedge focus-pointer (orange fade up).
  void _paintWedge(Canvas canvas) {
    final path = Path()
      ..moveTo(_c.dx, _c.dy)
      ..lineTo(_c.dx - 34, _c.dy - 150)
      ..arcToPoint(
        Offset(_c.dx + 34, _c.dy - 150),
        radius: const Radius.circular(154),
      )
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(_c.dx, _c.dy),
          Offset(_c.dx, _c.dy - 150),
          const <Color>[Color(0x00FF7A18), Color(0x3DFF7A18)],
        ),
    );
  }

  void _paintLabels(Canvas canvas) {
    final n = labels.length;
    if (n == 0) return;
    for (var i = 0; i < n; i++) {
      final ang = _rad(-90 + i * 360 / n + rotation);
      final x = _c.dx + RingDiveGeo.labelR * math.cos(ang);
      final y = _c.dy + RingDiveGeo.labelR * math.sin(ang);
      final isF = i == focus;

      if (isF) {
        canvas
          ..drawCircle(
            Offset(x, y),
            23,
            Paint()..color = const Color(0x24FF7A18),
          )
          ..drawCircle(
            Offset(x, y),
            23,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5
              ..color = const Color(0xE6FF7A18),
          );
      }

      final dot = i < dots.length ? dots[i] : null;
      if (dot != null) {
        canvas
          ..drawCircle(Offset(x, y - 13), 4.5, Paint()..color = dot)
          ..drawCircle(
            Offset(x, y - 13),
            4.5,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.8
              ..color = const Color(0x40000000),
          );
      }

      _drawLabel(canvas, labels[i], Offset(x, y), focused: isF);
    }
  }

  void _drawLabel(Canvas canvas, String text, Offset at, {required bool focused}) {
    // The focused label (exactly one) restyles as the wheel turns, so build it
    // live; every unfocused label is stable, so reuse the cached pair.
    final (halo, fill) =
        focused ? _buildLabel(text, focused: true) : _unfocusedFor(text);
    halo.paint(canvas, Offset(at.dx - halo.width / 2, at.dy - halo.height / 2));
    fill.paint(canvas, Offset(at.dx - fill.width / 2, at.dy - fill.height / 2));
  }

  /// Cached halo+fill pair for [text] in the unfocused style.
  (TextPainter, TextPainter) _unfocusedFor(String text) =>
      _unfocusedCache[text] ??= _buildLabel(text, focused: false);

  /// Lays out the halo (white stroke) and fill [TextPainter]s for [text].
  (TextPainter, TextPainter) _buildLabel(String text, {required bool focused}) {
    final len = text.length;
    final fontSize = focused
        ? (len <= 3 ? 32.0 : (len <= 5 ? 28.0 : (len <= 8 ? 23.0 : 18.0)))
        : (len <= 3 ? 23.0 : (len <= 5 ? 20.0 : (len <= 8 ? 16.0 : 13.0)));
    final fillColor =
        focused ? const Color(0xFFE8690B) : const Color(0xB8465060);

    TextPainter build(Paint? fg, Color? color) => TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(
              fontFamily: 'Heebo',
              fontSize: fontSize,
              fontWeight: focused ? FontWeight.w800 : FontWeight.w700,
              color: color,
              foreground: fg,
            ),
          ),
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
        )..layout();

    final halo = build(
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = focused ? 4 : 3.5
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xEBFFFFFF),
      null,
    );
    final fill = build(null, fillColor);
    return (halo, fill);
  }

  @override
  bool shouldRepaint(_DialPainter old) =>
      old.rotation != rotation ||
      old.focus != focus ||
      old.lockedCount != lockedCount ||
      // The parent rebuilds a fresh labels list every frame, so identity always
      // differs even when the content is unchanged; compare content instead so
      // an unchanged wheel does not repaint (and the old painter's label cache
      // is kept — a content change swaps in this new painter with a fresh cache).
      !listEquals(old.labels, labels) ||
      !listEquals(old.dots, dots);
}
