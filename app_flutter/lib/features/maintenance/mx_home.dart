/// Maintenance module — the "בית" illustration kit (design round 4).
///
/// Every apartment is a small drawn house. Its state reads at a glance:
///   • ok      — sage roof and door, warm lit windows;
///   • job     — petrol roof and door, a wrench bubble above;
///   • urgent  — red roof and door, a "!" bubble and a breathing red glow.
/// Red stays reserved for danger: roofs are never red otherwise.
/// The same house appears on the board street, the apartment header, the
/// success moment (door open, warm light) and the quote cover.
library;

import 'package:buildsmart/features/maintenance/mx_brand.dart';
import 'package:buildsmart/features/maintenance/mx_icons.dart';
import 'package:flutter/material.dart';

enum MxHouseState { ok, job, urgent }

const Color _wall = Color(0xFFFFFDF8);
const Color _wallLine = Color(0xFFE8DCCB);
const Color _frame = Color(0xFFE2D2BD);
const Color _bush = Color(0xFFA9C39E);

Color mxHouseColor(MxHouseState s) => switch (s) {
  MxHouseState.ok => kMxSage,
  MxHouseState.job => kMxPrimary,
  MxHouseState.urgent => kMxBad,
};

bool _still(BuildContext c) => MediaQuery.maybeDisableAnimationsOf(c) ?? false;

/// Draws one house on a 76 × 96 grid, scaled to the canvas.
/// [door] 0 = closed, 1 = wide open with warm light (the success moment);
/// [glow] scales the urgent halo (0–1, breathing); [lit] 0–1 brightens the
/// windows (Friday's "שבת שלום" street).
class MxHousePainter extends CustomPainter {
  MxHousePainter(
    this.state, {
    this.door = 0,
    this.glow = 1,
    this.lit = 0,
    this.bubble = true,
  });
  final MxHouseState state;
  final double door;
  final double glow;
  final double lit;
  final bool bubble;

  static final Path _wrench = mxParsePath(MxGlyphs.wrench.d);

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / 76, size.height / 96);
    final roof = mxHouseColor(state);
    final win =
        Color.lerp(
          state == MxHouseState.urgent ? const Color(0xFFFFF3E6) : kMxWindow,
          const Color(0xFFFFD36B),
          lit,
        )!;
    final fill = Paint()..style = PaintingStyle.fill;

    if (state == MxHouseState.urgent && glow > 0) {
      canvas.drawCircle(
        const Offset(38, 58),
        36,
        Paint()
          ..shader = RadialGradient(
            colors: [
              kMxBad.withValues(alpha: 0.38 * glow),
              kMxBad.withValues(alpha: 0),
            ],
          ).createShader(
            Rect.fromCircle(center: const Offset(38, 58), radius: 36),
          ),
      );
    }
    if (lit > 0) {
      canvas.drawCircle(
        const Offset(38, 62),
        34,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFFD36B).withValues(alpha: 0.4 * lit),
              const Color(0x00FFD36B),
            ],
          ).createShader(
            Rect.fromCircle(center: const Offset(38, 62), radius: 34),
          ),
      );
    }
    // ground shadow
    canvas
      ..drawOval(
        Rect.fromCenter(center: const Offset(38, 92), width: 60, height: 7),
        Paint()..color = const Color(0x14000000),
      )
      // chimney
      ..drawRRect(
        RRect.fromLTRBR(49, 22, 56, 36, const Radius.circular(1.5)),
        Paint()..color = roof.withValues(alpha: 0.85),
      );
    // walls
    final wall =
        Path()
          ..moveTo(14, 46)
          ..lineTo(14, 88)
          ..lineTo(62, 88)
          ..lineTo(62, 46);
    canvas
      ..drawPath(wall, fill..color = _wall)
      ..drawPath(
        wall,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = _wallLine,
      )
      // roof
      ..drawPath(
        Path()
          ..moveTo(6, 47)
          ..lineTo(38, 20)
          ..lineTo(70, 47),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = roof,
      )
      ..drawPath(
        Path()
          ..moveTo(18, 46)
          ..lineTo(38, 29)
          ..lineTo(58, 46)
          ..close(),
        fill..color = _wall,
      );
    final frame =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = _frame;
    canvas
      ..drawCircle(const Offset(38, 40), 3.4, fill..color = win)
      ..drawCircle(const Offset(38, 40), 3.4, frame);
    for (final x in [19.0, 46.0]) {
      final r = RRect.fromLTRBR(x, 54, x + 11, 65, const Radius.circular(2.5));
      canvas
        ..drawRRect(r, fill..color = win)
        ..drawRRect(r, frame)
        ..drawLine(Offset(x + 5.5, 54), Offset(x + 5.5, 65), frame)
        ..drawLine(Offset(x, 59.5), Offset(x + 11, 59.5), frame);
    }
    // door: an arch; when open, warm light inside and the leaf swung in.
    final doorway =
        Path()
          ..moveTo(31, 88)
          ..lineTo(31, 75)
          ..arcToPoint(const Offset(45, 75), radius: const Radius.circular(7))
          ..lineTo(45, 88)
          ..close();
    final o = door.clamp(0.0, 1.0);
    if (o == 0) {
      canvas
        ..drawPath(doorway, fill..color = roof)
        ..drawCircle(
          const Offset(41, 81),
          1.2,
          fill..color = Colors.white.withValues(alpha: 0.8),
        );
    } else {
      canvas
        ..drawPath(doorway, fill..color = const Color(0xFFFFE4A3))
        ..drawPath(
          Path()
            ..moveTo(33, 88)
            ..lineTo(43, 88)
            ..lineTo(43 + 9 * o, 94)
            ..lineTo(33 - 9 * o, 94)
            ..close(),
          fill..color = const Color(0xFFFFE4A3).withValues(alpha: 0.7 * o),
        );
      // the door leaf swings out toward the viewer, hinged on the left:
      // its free edge travels from the right jamb (45) to outside (24).
      const hinge = 31.0;
      final xe = 45 - 21 * o;
      final leaf =
          Path()
            ..moveTo(hinge, 88)
            ..lineTo(hinge, 74)
            ..quadraticBezierTo(
              (hinge + xe) / 2,
              66.5 - 1.5 * o,
              xe,
              74 - 2 * o,
            )
            ..lineTo(xe, 88 + 2 * o)
            ..close();
      canvas
        ..drawPath(leaf, fill..color = roof)
        ..drawCircle(
          Offset(xe + (hinge - xe) * 0.25, 81),
          1.2,
          fill..color = Colors.white.withValues(alpha: 0.8),
        );
    }
    // step + bushes
    canvas
      ..drawRRect(
        RRect.fromLTRBR(28, 87, 48, 90, const Radius.circular(1.5)),
        fill..color = _frame,
      )
      ..drawCircle(const Offset(13, 86), 5, fill..color = _bush)
      ..drawCircle(const Offset(63, 86), 4, fill..color = _bush);
    // status bubble
    if (bubble && state != MxHouseState.ok) {
      const c = Offset(52, 6);
      canvas
        ..drawCircle(c, 12.2, fill..color = Colors.white)
        ..drawCircle(c, 11, fill..color = roof);
      final ink =
          Paint()
            ..style = PaintingStyle.stroke
            ..color = Colors.white
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round;
      if (state == MxHouseState.urgent) {
        canvas
          ..drawLine(
            const Offset(52, 1),
            const Offset(52, 6.5),
            ink..strokeWidth = 2.6,
          )
          ..drawCircle(const Offset(52, 10.4), 1.4, fill..color = Colors.white);
      } else {
        canvas
          ..save()
          ..translate(45.5, -0.5)
          ..scale(0.54)
          ..drawPath(_wrench, ink..strokeWidth = 2.6)
          ..restore();
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(MxHousePainter old) =>
      old.state != state ||
      old.door != door ||
      old.glow != glow ||
      old.lit != lit ||
      old.bubble != bubble;
}

/// A house of [width] (height = width × 96/76). Urgent houses breathe
/// (6 slow cycles, then rest) unless reduce-motion is on.
class MxHouseArt extends StatefulWidget {
  const MxHouseArt({
    required this.state,
    this.width = 62,
    this.lit = 0,
    this.bubble = true,
    super.key,
  });
  final MxHouseState state;
  final double width;
  final double lit;
  final bool bubble;
  @override
  State<MxHouseArt> createState() => _MxHouseArtState();
}

class _MxHouseArtState extends State<MxHouseArt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
    value: 1,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(MxHouseArt old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (widget.state == MxHouseState.urgent && !_still(context)) {
      if (!_c.isAnimating) {
        _c
          ..value = 0.55
          ..repeat(min: 0.55, max: 1, reverse: true, count: 6);
      }
    } else {
      _c
        ..stop()
        ..value = 1;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder:
        (_, _) => CustomPaint(
          size: Size(widget.width, widget.width * 96 / 76),
          painter: MxHousePainter(
            widget.state,
            glow: _c.value,
            lit: widget.lit,
            bubble: widget.bubble,
          ),
        ),
  );
}

/// A small round tree for between the houses.
class MxTree extends StatelessWidget {
  const MxTree({this.height = 44, super.key});
  final double height;
  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size(height * 30 / 54, height),
    painter: _TreePainter(),
  );
}

class _TreePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.height / 54;
    canvas
      ..save()
      ..scale(s)
      ..drawRRect(
        RRect.fromLTRBR(13.5, 34, 16.5, 52, const Radius.circular(1.5)),
        Paint()..color = const Color(0xFFB49A7C),
      )
      ..drawOval(
        Rect.fromCenter(center: const Offset(15, 22), width: 26, height: 40),
        Paint()..color = const Color(0xFF9DBB91),
      )
      ..drawLine(
        const Offset(15, 10),
        const Offset(15, 36),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_TreePainter old) => false;
}

/// Morning sky: peach-to-cream gradient, sun, two soft clouds, two hills
/// and a path. [sun] is a fraction of the size (x from the left).
class MxSkyPainter extends CustomPainter {
  const MxSkyPainter({this.sun = const Offset(0.2, 0.32), this.night = 0});
  final Offset sun;

  /// 0 = morning; 1 = Friday-evening gold (the "שבת שלום" street).
  final double night;

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    final r = Offset.zero & s;
    canvas.drawRect(
      r,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(
              const Color(0xFFFCE3CF),
              const Color(0xFFF6C99A),
              night,
            )!,
            Color.lerp(
              const Color(0xFFFDF1E5),
              const Color(0xFFFBE2C4),
              night,
            )!,
            const Color(0xFFF3F1E4),
          ],
          stops: const [0, 0.6, 1],
        ).createShader(r),
    );
    final c = Offset(sun.dx * w, sun.dy * h);
    canvas
      ..drawCircle(c, 38, Paint()..color = const Color(0x59FBD58A))
      ..drawCircle(c, 24, Paint()..color = const Color(0xFFF6C766));
    final cloud = Paint()..color = Colors.white.withValues(alpha: 0.85);
    void puff(double x, double y, double k) {
      canvas
        ..drawOval(
          Rect.fromCenter(center: Offset(x, y), width: 52 * k, height: 18 * k),
          cloud,
        )
        ..drawOval(
          Rect.fromCenter(
            center: Offset(x + 16 * k, y - 6 * k),
            width: 32 * k,
            height: 18 * k,
          ),
          cloud,
        );
    }

    puff(w * (sun.dx > 0.5 ? 0.3 : 0.62), h * 0.42, 1);
    puff(w * (sun.dx > 0.5 ? 0.1 : 0.86), h * 0.3, 0.75);
    canvas
      ..drawPath(
        Path()
          ..moveTo(0, h * 0.72)
          ..quadraticBezierTo(w * 0.25, h * 0.6, w * 0.5, h * 0.7)
          ..quadraticBezierTo(w * 0.75, h * 0.8, w, h * 0.66)
          ..lineTo(w, h)
          ..lineTo(0, h)
          ..close(),
        Paint()..color = const Color(0xFFDDE8D3),
      )
      ..drawPath(
        Path()
          ..moveTo(0, h * 0.86)
          ..quadraticBezierTo(w * 0.3, h * 0.78, w * 0.6, h * 0.85)
          ..quadraticBezierTo(w * 0.8, h * 0.9, w, h * 0.83)
          ..lineTo(w, h)
          ..lineTo(0, h)
          ..close(),
        Paint()..color = const Color(0xFFCFDFC3),
      )
      ..drawRect(
        Rect.fromLTWH(0, h * 0.93 - 5, w, 10),
        Paint()..color = const Color(0xFFE9DCC6),
      );
  }

  @override
  bool shouldRepaint(MxSkyPainter old) => old.sun != sun || old.night != night;
}

/// A rounded "window onto the street": the sky behind [child].
class MxScene extends StatelessWidget {
  const MxScene({
    required this.child,
    this.height = 262,
    this.sun = const Offset(0.2, 0.35),
    this.night = 0,
    this.radius = 28,
    super.key,
  });
  final Widget child;
  final double height;
  final Offset sun;
  final double night;
  final double radius;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: SizedBox(
      height: height,
      child: CustomPaint(
        painter: MxSkyPainter(sun: sun, night: night),
        child: child,
      ),
    ),
  );
}

/// The neighbourhood hardware store, drawn (250 × 170 grid): petrol sign,
/// a scalloped gold-and-cream awning, shop windows with goods, an arch door.
class MxStorefront extends StatelessWidget {
  const MxStorefront({required this.name, this.width = 250, super.key});
  final String name;
  final double width;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      size: Size(width, width * 170 / 250),
      painter: _StorePainter(name),
    ),
  );
}

class _StorePainter extends CustomPainter {
  _StorePainter(this.name);
  final String name;
  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / 250);
    final fill = Paint();
    final line =
        Paint()
          ..style = PaintingStyle.stroke
          ..color = kMxPrimary
          ..strokeWidth = 2.5
          ..strokeJoin = StrokeJoin.round;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(125, 166), width: 220, height: 8),
      fill..color = const Color(0x12000000),
    );
    final body = RRect.fromLTRBR(24, 62, 226, 166, const Radius.circular(6));
    canvas
      ..drawRRect(body, fill..color = _wall)
      ..drawRRect(body, line)
      ..drawPath(
        Path()
          ..moveTo(12, 64)
          ..lineTo(238, 64)
          ..lineTo(226, 26)
          ..lineTo(24, 26)
          ..close(),
        fill..color = kMxPrimary,
      );
    for (var i = 0; i < 8; i++) {
      final x = 20.0 + i * 25;
      final p =
          Path()
            ..moveTo(x, 64)
            ..quadraticBezierTo(x + 12.5, 82, x + 25, 64)
            ..close();
      canvas
        ..drawPath(p, fill..color = i.isEven ? kMxAccent : _wall)
        ..drawPath(
          p,
          Paint()
            ..style = PaintingStyle.stroke
            ..color = kMxPrimary
            ..strokeWidth = 2,
        );
    }
    final door =
        Path()
          ..moveTo(104, 166)
          ..lineTo(104, 124)
          ..arcToPoint(
            const Offset(146, 124),
            radius: const Radius.circular(21),
          )
          ..lineTo(146, 166);
    canvas
      ..drawPath(door, fill..color = kMxPeach)
      ..drawPath(door, line);
    for (final x in [38.0, 164.0]) {
      final r = RRect.fromLTRBR(x, 98, x + 48, 138, const Radius.circular(5));
      canvas
        ..drawRRect(r, fill..color = kMxTealTint)
        ..drawRRect(r, line..strokeWidth = 2);
    }
    void good(double l, double t, double w, double h, Color c) =>
        canvas.drawRRect(
          RRect.fromLTRBR(l, t, l + w, t + h, const Radius.circular(2)),
          fill..color = c,
        );
    good(44, 120, 10, 14, kMxAccent);
    good(58, 114, 8, 20, kMxSage);
    good(70, 124, 10, 10, kMxBad.withValues(alpha: 0.8));
    good(170, 118, 14, 16, kMxAccent);
    good(188, 122, 16, 12, kMxSage);
    canvas
      ..drawCircle(const Offset(18, 150), 10, fill..color = _bush)
      ..drawCircle(const Offset(234, 152), 8, fill..color = _bush);
    final tp = TextPainter(
      text: TextSpan(
        text: name,
        style: const TextStyle(
          fontFamily: kMxFont,
          fontWeight: FontWeight.w700,
          fontSize: 17,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.rtl,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: 190);
    tp.paint(canvas, Offset(125 - tp.width / 2, 45 - tp.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_StorePainter old) => old.name != name;
}

/// A tinted rounded-square icon box (the "בית" icon container).
class MxIconBox extends StatelessWidget {
  const MxIconBox(
    this.icon, {
    this.color = kMxPrimary,
    this.background,
    this.size = 44,
    super.key,
  });

  /// [MxGlyph] or [IconData].
  final Object icon;
  final Color color;
  final Color? background;
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: background ?? mxBoxTint(color),
      borderRadius: BorderRadius.circular(size * 0.34),
    ),
    child: mxIcon(icon, size: size >= 44 ? 23 : 20, color: color),
  );
}

/// Tint behind a status color in an icon box.
Color mxBoxTint(Color c) {
  if (c == kMxBad) return kMxPink;
  if (c == kMxWarn || c == kMxAccent) return kMxGoldTint;
  if (c == kMxOk || c == kMxSage) return kMxSageTint;
  if (c == Colors.white) return Colors.white24;
  return kMxTealTint;
}
