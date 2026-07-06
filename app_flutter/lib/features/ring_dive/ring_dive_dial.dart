/// RingDive — the knurled machined dial, drawn with a single [CustomPainter]
/// (P1). PURE geometry ported from the design handoff prototype
/// (`RingDive-Prototype.dc.html` → `renderVals()`); no engine, no state, no
/// interaction yet — a static render parameterised by `rotation` (P3 drives it)
/// and `lockedCount` (P4 drives it from the dive depth).
///
/// CONVENTION (README "The Dial"): 0° = 3 o'clock, increasing clockwise, 12:00 =
/// −90°. The container is 320×320, the active dial box 236×236 centred in it, so
/// the dial centre sits at (160, 160) in container coordinates and everything is
/// painted there. One `CustomPaint` (not a widget-per-pad) keeps it cheap enough
/// to repaint every drag frame on CanvasKit web (P3).
library;

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Static geometry from the handoff (all in container-space, container = 320).
class RingDiveGeo {
  const RingDiveGeo._();

  static const double container = 320; // wheel container box
  static const double center = 160; // container centre (both axes)
  static const double dialBox = 236; // active dial diameter
  static const double dialRadius = 118; // dialBox / 2
  static const double gripRadius = 108; // pad ring radius from centre
  static const double holeSize = 152; // center groove diameter
  static const int padCount = 20;
  static const double padStepDeg = 360 / padCount; // 18°
}

/// The dial. Sizes itself to the 320×320 wheel container; paint is delegated to
/// [_DialPainter]. [rotation] is in DEGREES (0 for the static P1 render).
class RingDiveDial extends StatelessWidget {
  const RingDiveDial({
    this.rotation = 0,
    this.lockedCount = 0,
    super.key,
  });

  /// Current wheel rotation in degrees (P3 supplies the live/dragged value).
  final double rotation;

  /// How many axes are already locked (P4 supplies the dive depth) — drawn as
  /// concentric rings inside the dial. 0 in the base state.
  final int lockedCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: RingDiveGeo.container,
      height: RingDiveGeo.container,
      child: CustomPaint(
        painter: _DialPainter(rotation: rotation, lockedCount: lockedCount),
        size: const Size.square(RingDiveGeo.container),
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  _DialPainter({required this.rotation, required this.lockedCount});

  final double rotation;
  final int lockedCount;

  static const Offset _c = Offset(RingDiveGeo.center, RingDiveGeo.center);

  @override
  void paint(Canvas canvas, Size size) {
    _paintGroundShadow(canvas);
    _paintDropShadow(canvas);
    _paintBaseDisc(canvas);
    _paintTopGloss(canvas);
    _paintGripPads(canvas);
    _paintCenterGroove(canvas);
    _paintLockedRings(canvas);
    _paintPointer(canvas);
  }

  double _deg2rad(double d) => d * math.pi / 180;

  /// Soft radial contact shadow under the dial (prototype: 252px @ (160,172)).
  void _paintGroundShadow(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0x33785C36)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    canvas.drawCircle(const Offset(160, 172), 126, paint);
  }

  /// The disc's warm drop shadow (CSS `0 26px 50px -10px …` + a softer layer).
  void _paintDropShadow(Canvas canvas) {
    canvas
      ..drawCircle(
        _c + const Offset(0, 20),
        RingDiveGeo.dialRadius - 6,
        Paint()
          ..color = const Color(0x6B785F3A)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
      )
      ..drawCircle(
        _c + const Offset(0, 8),
        RingDiveGeo.dialRadius,
        Paint()
          ..color = const Color(0x33785F3A)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
      );
  }

  /// The machined disc face: radial gradient `circle at 50% 32%`.
  void _paintBaseDisc(Canvas canvas) {
    // Gradient origin at (50%, 32%) of the 236 disc box centred on _c.
    const origin = Offset(
      RingDiveGeo.center,
      RingDiveGeo.center - RingDiveGeo.dialRadius + 0.32 * RingDiveGeo.dialBox,
    );
    final paint = Paint()
      ..shader = ui.Gradient.radial(
        origin,
        RingDiveGeo.dialBox * 0.62,
        const <Color>[
          Color(0xFFFFFFFF),
          Color(0xFFF9F6F1),
          Color(0xFFEFE8DE),
          Color(0xFFE6DDD0),
        ],
        const <double>[0, 0.46, 0.82, 1],
      );
    canvas.drawCircle(_c, RingDiveGeo.dialRadius, paint);
  }

  /// The top-of-disc white gloss (`radial-gradient(115% 78% at 50% 10% …)`).
  void _paintTopGloss(Canvas canvas) {
    const origin = Offset(
      RingDiveGeo.center,
      RingDiveGeo.center - RingDiveGeo.dialRadius + 0.10 * RingDiveGeo.dialBox,
    );
    canvas
      ..save()
      ..clipPath(
        Path()..addOval(Rect.fromCircle(center: _c, radius: RingDiveGeo.dialRadius)),
      )
      ..drawCircle(
        origin,
        RingDiveGeo.dialBox * 0.55,
        Paint()
          ..shader = ui.Gradient.radial(
            origin,
            RingDiveGeo.dialBox * 0.55,
            const <Color>[Color(0x99FFFFFF), Color(0x00FFFFFF)],
            const <double>[0, 0.46],
          ),
      )
      ..restore();
  }

  /// The pad currently aligned to the 12:00 marker (−90° on screen).
  int get _topPad =>
      ((( (-90 - rotation) / RingDiveGeo.padStepDeg).round() % 20) + 20) % 20;

  /// 20 knurled grip pads around the rim; the one at 12:00 is highlighted.
  void _paintGripPads(Canvas canvas) {
    final topPad = _topPad;
    for (var i = 0; i < RingDiveGeo.padCount; i++) {
      final on = i == topPad;
      // Position angle rides the wheel rotation (the pads spin rigidly).
      final a = _deg2rad(i * RingDiveGeo.padStepDeg + rotation);
      final pos = Offset(
        RingDiveGeo.center + RingDiveGeo.gripRadius * math.cos(a),
        RingDiveGeo.center + RingDiveGeo.gripRadius * math.sin(a),
      );
      final w = on ? 14.0 : 12.0;
      final h = on ? 30.0 : 26.0;
      canvas
        ..save()
        ..translate(pos.dx, pos.dy)
        ..rotate(_deg2rad(i * RingDiveGeo.padStepDeg + rotation + 90));
      final rrect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: w, height: h),
        const Radius.circular(6.5),
      );
      // Warm shadow first, then the orange body gradient.
      canvas
        ..drawRRect(
          rrect.shift(const Offset(0, 3)),
          Paint()
            ..color = on ? const Color(0x99F06907) : const Color(0x73964200)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, on ? 4 : 3),
        )
        ..drawRRect(
          rrect,
          Paint()
            ..shader = ui.Gradient.linear(
              Offset(0, -h / 2),
              Offset(0, h / 2),
              on
                  ? const <Color>[
                      Color(0xFFFFD09A),
                      Color(0xFFFF9A3F),
                      Color(0xFFF06E08),
                    ]
                  : const <Color>[
                      Color(0xFFFFB668),
                      Color(0xFFFF8B2C),
                      Color(0xFFEE6907),
                    ],
              on ? const <double>[0, 0.44, 1] : const <double>[0, 0.46, 1],
            ),
        )
        ..restore();
    }
  }

  /// The recessed center groove — concentric machined rings + inset shade.
  void _paintCenterGroove(Canvas canvas) {
    const r = RingDiveGeo.holeSize / 2;
    canvas
      ..save()
      ..clipPath(Path()..addOval(Rect.fromCircle(center: _c, radius: r)))
      // Repeating radial rings (period 5.5px: 2.5 dark / 3 light).
      ..drawCircle(
        _c,
        r,
        Paint()
          ..shader = ui.Gradient.radial(
            _c,
            5.5,
            const <Color>[
              Color(0xFFE3DBCD),
              Color(0xFFE3DBCD),
              Color(0xFFF5F1EA),
              Color(0xFFF5F1EA),
            ],
            const <double>[0, 0.4545, 0.4545, 1],
            TileMode.repeated,
          ),
      )
      // Inset shade at the rim of the recess.
      ..drawCircle(
        _c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..color = const Color(0x806E5A3E)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      )
      ..restore();
  }

  /// Concentric locked-depth rings (most recent = orange). 0 in the base state;
  /// P4 supplies [lockedCount] from the dive stack.
  void _paintLockedRings(Canvas canvas) {
    if (lockedCount <= 0) return;
    const outerR = 100.0;
    const innerR = 46.0;
    const maxSpan = 22.0;
    final double span;
    if (lockedCount > 1) {
      span = math.min((outerR - innerR) / (lockedCount - 1), maxSpan);
    } else {
      span = 0.0;
    }
    for (var j = 0; j < lockedCount; j++) {
      final radius = outerR - j * span;
      final recent = j == 0;
      canvas.drawCircle(
        _c,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = recent ? 2.5 : 1.5
          ..color =
              recent ? const Color(0x8CFF7A18) : const Color(0x42968469),
      );
    }
  }

  /// The fixed 12:00 marker: soft halo + downward triangle + dot. Does NOT
  /// rotate with the wheel — it marks where selection happens.
  void _paintPointer(Canvas canvas) {
    // Halo.
    canvas.drawCircle(
      const Offset(160, 48),
      33,
      Paint()
        ..shader = ui.Gradient.radial(
          const Offset(160, 48),
          33,
          const <Color>[Color(0x33FF7A18), Color(0x00FF7A18)],
          const <double>[0, 0.7],
        ),
    );
    // Downward triangle (16 wide × 12 tall) with its tip at ~y=17.
    final tri = Path()
      ..moveTo(152, 5)
      ..lineTo(168, 5)
      ..lineTo(160, 17)
      ..close();
    // Triangle + dot below it.
    canvas
      ..drawPath(tri, Paint()..color = const Color(0xFFFF7A18))
      ..drawCircle(
        const Offset(160, 20),
        6.5,
        Paint()..color = const Color(0x2EFF7A18),
      )
      ..drawCircle(
        const Offset(160, 20),
        2.5,
        Paint()..color = const Color(0xFFFF7A18),
      );
  }

  @override
  bool shouldRepaint(_DialPainter old) =>
      old.rotation != rotation || old.lockedCount != lockedCount;
}
