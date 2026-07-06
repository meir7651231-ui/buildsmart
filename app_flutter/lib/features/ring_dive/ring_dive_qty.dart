/// RingDive Pro-X-Light — the QUANTITY dual number-ring (RD-V3). Two concentric
/// scales over the same warm plate: tens (00–90) on the outer r124 ring, units
/// (0–9) on the inner r84 ring, summed to 0–99. Ported from the prototype's
/// quantity phase (`qtyTens`/`qtyUnits`/`qtySpin` + the dual-drag in `pMove`):
///
/// - the FIRST drag direction picks which ring turns — counter-clockwise spins
///   tens, clockwise spins units (the design's `_dragMode`), so one gesture sets
///   one digit; a second gesture the other.
/// - a tap on a number snaps that number's ring straight to it.
/// - on release each ring snaps to its nearest detent; a light haptic per step.
///
/// The plate/ticks/wedge background is the shared `RingDiveDial` with no labels;
/// this widget paints only the two number scales + the central "+" and reports
/// the live value up via `onChanged`. The confirm ("add to cart") lives on the
/// screen. Still dark unless `kRingDiveFlag` is on (the screen gates it).
library;

import 'dart:math' as math;

import 'package:buildsmart/features/ring_dive/ring_dive_dial.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;

class RingDiveQty extends StatefulWidget {
  const RingDiveQty({
    required this.onChanged,
    this.initial = 0,
    this.lockedCount = 0,
    this.size = 340,
    super.key,
  });

  /// Fired with the live 0–99 value on every drag step, tap, and snap.
  final ValueChanged<int> onChanged;

  /// The value to seed the rings from (0–99).
  final int initial;

  /// Dive depth → the locked rings drawn by the background dial.
  final int lockedCount;

  final double size;

  @override
  State<RingDiveQty> createState() => _RingDiveQtyState();
}

class _RingDiveQtyState extends State<RingDiveQty> {
  double _rotT = 0; // tens-ring rotation (deg)
  double _rot = 0; // units-ring rotation (deg)

  double _startAngle = 0;
  double _moved = 0;
  String? _dragMode; // 'tens' | 'units' — locked on the first move
  bool _dragging = false;

  static const Offset _center = Offset(170, 170);

  @override
  void initState() {
    super.initState();
    final q = widget.initial.clamp(0, 99);
    _rotT = -((q ~/ 10) * 36).toDouble();
    _rot = -((q % 10) * 36).toDouble();
  }

  bool get _reduceMotion =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;

  int _focusIndex(double rot) => (((-rot / 36).round() % 10) + 10) % 10;

  int get _value => _focusIndex(_rotT) * 10 + _focusIndex(_rot);

  double _angleDeg(Offset local) {
    // widget px → dial space (viewBox 444 mapped by scale + translate(52,52)).
    final s = widget.size / RingDiveGeo.viewBox;
    final p = Offset(local.dx / s - 52, local.dy / s - 52);
    final d = p - _center;
    return math.atan2(d.dy, d.dx) * 180 / math.pi;
  }

  double _distToCenter(Offset local) {
    final s = widget.size / RingDiveGeo.viewBox;
    final p = Offset(local.dx / s - 52, local.dy / s - 52);
    return (p - _center).distance;
  }

  double _norm(double a) => ((a + 180) % 360 + 360) % 360 - 180;

  void _onPanStart(DragStartDetails d) {
    _dragging = true;
    _startAngle = _angleDeg(d.localPosition);
    _moved = 0;
    _dragMode = null;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (!_dragging) return;
    final cur = _angleDeg(d.localPosition);
    final delta = _norm(cur - _startAngle);
    _startAngle = cur;
    _moved += delta.abs();
    // The first meaningful move decides the ring: CCW (delta<0) → tens.
    if (_dragMode == null) {
      if (_moved <= 6) return;
      _dragMode = delta < 0 ? 'tens' : 'units';
    }
    final beforeT = _focusIndex(_rotT);
    final beforeU = _focusIndex(_rot);
    setState(() {
      if (_dragMode == 'tens') {
        _rotT += delta;
      } else {
        _rot += delta;
      }
    });
    final changed = _dragMode == 'tens'
        ? _focusIndex(_rotT) != beforeT
        : _focusIndex(_rot) != beforeU;
    if (changed && !_reduceMotion) HapticFeedback.selectionClick();
    widget.onChanged(_value);
  }

  void _onPanEnd(DragEndDetails d) {
    if (!_dragging) return;
    _dragging = false;
    _dragMode = null;
    setState(() {
      _rotT = (_rotT / 36).round() * 36;
      _rot = (_rot / 36).round() * 36;
    });
    widget.onChanged(_value);
  }

  void _onTapUp(TapUpDetails d) {
    final dist = _distToCenter(d.localPosition);
    // nearer to the r124 track → tens; nearer r84 → units.
    final tens = (dist - 124).abs() <= (dist - 84).abs();
    final rot = tens ? _rotT : _rot;
    final ang = _angleDeg(d.localPosition);
    final idx = ((((ang + 90 - rot) / 36).round() % 10) + 10) % 10;
    if (!_reduceMotion) HapticFeedback.selectionClick();
    setState(() {
      final snapped = -(idx * 36).toDouble();
      if (tens) {
        _rotT = snapped;
      } else {
        _rot = snapped;
      }
    });
    widget.onChanged(_value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onTapUp: _onTapUp,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RingDiveDial(
            lockedCount: widget.lockedCount,
            size: widget.size,
          ),
          CustomPaint(
            size: Size.square(widget.size),
            painter: _QtyPainter(rotT: _rotT, rot: _rot),
          ),
          _hub(),
        ],
      ),
    );
  }

  /// The center hub in qty mode — the live × value (the product image slot is
  /// wired in RD-F). IgnorePointer so drags/taps reach the wheel.
  Widget _hub() {
    return IgnorePointer(
      child: Container(
        width: 112,
        height: 112,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xEBFFFFFF),
          border: Border.all(color: const Color(0x73FF7A18), width: 1.5),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x40FF7A18),
              blurRadius: 40,
              spreadRadius: -8,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'כמות',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: Color(0xFFE8690B),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '×$_value',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 30,
                fontWeight: FontWeight.w800,
                height: 1,
                color: Color(0xFF1B1B1A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyPainter extends CustomPainter {
  _QtyPainter({required this.rotT, required this.rot});

  final double rotT;
  final double rot;

  static const Offset _c = Offset(RingDiveGeo.cx, RingDiveGeo.cy);
  static const List<int> _tens = <int>[0, 10, 20, 30, 40, 50, 60, 70, 80, 90];
  static const List<int> _units = <int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

  double _rad(double deg) => deg * math.pi / 180;

  int _focusIndex(double r) => (((-r / 36).round() % 10) + 10) % 10;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / RingDiveGeo.viewBox;
    canvas
      ..save()
      ..scale(s)
      ..translate(52, 52);

    _paintScale(canvas, _tens, 124, rotT, tens: true);
    _paintScale(canvas, _units, 84, rot, tens: false);
    _drawText(canvas, '+', Offset(_c.dx, _c.dy - 104), 15, focused: true);

    canvas.restore();
  }

  void _paintScale(
    Canvas canvas,
    List<int> vals,
    double rr,
    double rotv, {
    required bool tens,
  }) {
    _dashedCircle(
      canvas,
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = const Color(0x2EFF7A18),
      dash: 2,
      gap: 7,
    );
    final focus = _focusIndex(rotv);
    for (var i = 0; i < vals.length; i++) {
      final ang = _rad(-90 + i * 36 + rotv);
      final x = _c.dx + rr * math.cos(ang);
      final y = _c.dy + rr * math.sin(ang);
      final isF = i == focus;
      if (isF) {
        canvas
          ..drawCircle(
            Offset(x, y),
            17,
            Paint()..color = const Color(0x24FF7A18),
          )
          ..drawCircle(
            Offset(x, y),
            17,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5
              ..color = const Color(0xE6FF7A18),
          );
      }
      final label = tens
          ? (vals[i] == 0 ? '00' : '${vals[i]}')
          : '${vals[i]}';
      _drawText(canvas, label, Offset(x, y), isF ? 21 : 17, focused: isF);
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
      canvas.drawArc(
        Rect.fromCircle(center: _c, radius: r),
        a0,
        dash / r,
        false,
        paint,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset at,
    double fontSize, {
    required bool focused,
  }) {
    TextPainter build(Paint? fg, Color? color) => TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: fontSize,
              fontWeight: focused ? FontWeight.w800 : FontWeight.w700,
              color: color,
              foreground: fg,
            ),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        )..layout();

    final halo = build(
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = focused ? 3.5 : 3
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xF2FFFFFF),
      null,
    );
    final fill = build(
      null,
      focused ? const Color(0xFFE8690B) : const Color(0x8C465060),
    );
    halo.paint(canvas, Offset(at.dx - halo.width / 2, at.dy - halo.height / 2));
    fill.paint(canvas, Offset(at.dx - fill.width / 2, at.dy - fill.height / 2));
  }

  @override
  bool shouldRepaint(_QtyPainter old) => old.rotT != rotT || old.rot != rot;
}
