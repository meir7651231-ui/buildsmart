// ✨ GoldButton — כפתור-פרימיום מקסימלי: label + onTap? + icon? + loading + kind.
// פאס-מקסימום (כל הסקילים, שכבה על שכבה, אטום יחיד):
//  · טבעת-קונכית מסתובבת (conic SweepGradient) עם bloom מטושטש + קו-חד
//  · גוף אורורה-מש חי (עומק + שתי עדשות-RadialGradient) + שפה-עליונה מוארת (specular)
//  · חלקיקי-נצנוץ פנימיים (deterministic twinkle) · ברק-זכוכית חולף
//  · זוהר-נשימה חיצוני (sin) · tilt-3D בתגובה לריחוף (Matrix4 perspective) + נצנוץ-עוקב-סמן
//  · מיקרו-לחיצה עם עומק-מתכווץ · כל המצבים: hover/press/focus/loading/disabled.
// הכל ממנוע-אנימציה יחיד. a11y: Semantics(button) · reduced-motion מקפיא-תנועה ·
// פוקוס-מקלדת (FocusableActionDetector) · touch≥48 · אין-צבע-לבד.
// חוט-טהור: material + dart:math בלבד · פיגמנט const · טקסט דרך פרמטר · RTL. אומת 3×.
import 'dart:math' as math;
import 'package:flutter/material.dart';

enum GoldButtonKind { primary, secondary, ghost }

class GoldButton extends StatefulWidget {
  const GoldButton({
    required this.label,
    this.onTap,
    this.icon,
    this.loading = false,
    this.kind = GoldButtonKind.primary,
    super.key,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool loading;
  final GoldButtonKind kind;

  // ── טוקנים ──
  static const _onAccent = Color(0xFFFFFFFF);
  static const _ink = Color(0xFFF4F5F7);
  static const _muted = Color(0xFF9AA0AC);
  static const _hair = Color(0x1FFFFFFF);
  static const _ring = Color(0xFF9C8CFF);
  static const _radius = 15.0;

  // גוף-אורורה (מבטא-אינדיגו · לבן עליו עובר 4.5:1)
  static const _bodyA = Color(0xFF7A6BFF);
  static const _bodyB = Color(0xFF5B4CE0);
  static const _bodyC = Color(0xFF3E31B0);
  static const _auroraViolet = Color(0x669D7BFF);
  static const _auroraCyan = Color(0x4622D3EE);
  static const _glow = Color(0xFF6C5CE7);

  // טבעת-הקונכית (conic)
  static const _ringHi = Color(0xFFB9AEFF);
  static const _ringLo = Color(0xFF5B4CE0);
  static const _ringCyan = Color(0xFF39D6F0);
  static const _ringMag = Color(0xFFC66BFF);

  // משטח secondary
  static const _surfaceTop = Color(0xFF1C1D26);
  static const _surface = Color(0xFF14141B);

  @override
  State<GoldButton> createState() => _GoldButtonState();
}

class _GoldButtonState extends State<GoldButton> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 4200))..repeat();
  final GlobalKey _key = GlobalKey();
  bool _pressed = false;
  bool _focused = false;
  bool _hover = false;
  double _hx = 0; // ריחוף -1..1
  double _hy = 0;

  bool get _enabled => widget.onTap != null && !widget.loading;
  bool get _primary => widget.kind == GoldButtonKind.primary;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _onHover(Offset local) {
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final s = box.size;
    setState(() {
      _hover = true;
      _hx = (local.dx / s.width) * 2 - 1;
      _hy = (local.dy / s.height) * 2 - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    final k = widget.kind;

    final fg = _primary
        ? GoldButton._onAccent
        : k == GoldButtonKind.secondary
            ? GoldButton._ink
            : GoldButton._muted;

    final content = widget.loading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
                strokeWidth: 2, valueColor: AlwaysStoppedAnimation(GoldButton._onAccent)),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 18, color: fg),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: TextStyle(
                    color: fg, fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.1),
              ),
            ],
          );

    final visual = AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = reduce ? 0.12 : _c.value;
        final breathe = reduce ? 0.5 : 0.5 + 0.5 * math.sin(t * 2 * math.pi);
        final down = _pressed && _enabled;
        final hot = _hover && _enabled && !down;

        // זוהר-נשימה חיצוני (primary) — מתעצם בריחוף, מתכווץ בלחיצה
        final glowA = down ? 0.24 : (0.34 + 0.16 * breathe) * (hot ? 1.18 : 1.0);
        final glowBlur = down ? 10.0 : (22 + 12 * breathe) + (hot ? 8 : 0);
        final shadows = <BoxShadow>[
          if (_focused) const BoxShadow(color: GoldButton._ring, spreadRadius: 2.5),
          if (_primary && _enabled) ...[
            BoxShadow(
              color: GoldButton._glow.withValues(alpha: glowA.clamp(0.0, 1.0)),
              blurRadius: glowBlur,
              spreadRadius: down ? -3 : 0,
              offset: Offset(0, down ? 4 : 12),
            ),
            const BoxShadow(color: Color(0x40000000), blurRadius: 8, offset: Offset(0, 3)),
          ],
        ];

        // tilt-3D בתגובה לריחוף (מכובה ב-reduced-motion)
        final tiltX = (hot && !reduce) ? -_hy * 0.12 : 0.0;
        final tiltY = (hot && !reduce) ? _hx * 0.14 : 0.0;
        final m = Matrix4.identity()
          ..setEntry(3, 2, 0.0016)
          ..rotateX(tiltX)
          ..rotateY(tiltY);

        final card = AnimatedScale(
          scale: down ? 0.97 : 1,
          duration: Duration(milliseconds: reduce ? 0 : 110),
          curve: Curves.easeOut,
          child: Container(
            key: _key,
            height: 48,
            decoration: BoxDecoration(
              color: k == GoldButtonKind.ghost ? Colors.transparent : null,
              borderRadius: BorderRadius.circular(GoldButton._radius),
              boxShadow: shadows,
            ),
            child: Stack(
              children: [
                // ── גוף מרובד ──
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(GoldButton._radius),
                    child: _primary
                        ? _primaryBody(t, hot)
                        : DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: k == GoldButtonKind.secondary
                                  ? const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [GoldButton._surfaceTop, GoldButton._surface])
                                  : null,
                              border: k == GoldButtonKind.ghost
                                  ? null
                                  : const Border.fromBorderSide(
                                      BorderSide(color: GoldButton._hair)),
                              borderRadius: BorderRadius.circular(GoldButton._radius),
                            ),
                          ),
                  ),
                ),
                // ── טבעת-קונכית מסתובבת ──
                if (_primary)
                  Positioned.fill(child: CustomPaint(painter: _GlowRing(t, enabled: _enabled))),
                // ── תוכן ──
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
                    child: Center(child: content),
                  ),
                ),
              ],
            ),
          ),
        );

        return Transform(alignment: Alignment.center, transform: m, child: card);
      },
    );

    final interactive = MouseRegion(
      onEnter: _enabled ? (_) => setState(() => _hover = true) : null,
      onExit: _enabled
          ? (_) => setState(() {
                _hover = false;
                _hx = 0;
                _hy = 0;
              })
          : null,
      onHover: _enabled ? (e) => _onHover(e.localPosition) : null,
      cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _enabled ? widget.onTap : null,
        onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
        child: visual,
      ),
    );

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.label,
      child: Opacity(
        opacity: _enabled ? 1 : 0.5,
        child: FocusableActionDetector(
          enabled: _enabled,
          onShowFocusHighlight: (v) => setState(() => _focused = v),
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
              widget.onTap?.call();
              return null;
            }),
          },
          child: interactive,
        ),
      ),
    );
  }

  // גוף primary: עומק + אורורה + שפה-מוארת + חלקיקים + ברק + נצנוץ-עוקב-סמן.
  Widget _primaryBody(double t, bool hot) {
    final sweepX = -0.35 + ((t / 0.42) % 1) * 1.7;
    final sweepActive = t < 0.42;
    return Stack(
      children: [
        // בסיס-עומק
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [GoldButton._bodyA, GoldButton._bodyB, GoldButton._bodyC],
                stops: [0, 0.5, 1],
              ),
            ),
          ),
        ),
        // עדשת-אורורה סגולה (שמאל-עליון)
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.7, -0.9),
                radius: 1.1,
                colors: [GoldButton._auroraViolet, Color(0x00000000)],
              ),
            ),
          ),
        ),
        // עדשת-אורורה טורקיז (ימין-תחתון)
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.9, 1),
                radius: 1.2,
                colors: [GoldButton._auroraCyan, Color(0x00000000)],
              ),
            ),
          ),
        ),
        // חלקיקי-נצנוץ פנימיים
        Positioned.fill(child: CustomPaint(painter: _Sparkles(t))),
        // נצנוץ-עוקב-סמן (רק בריחוף)
        if (hot)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(_hx, _hy),
                  radius: 0.9,
                  colors: const [Color(0x38FFFFFF), Color(0x00FFFFFF)],
                ),
              ),
            ),
          ),
        // שפה-עליונה מוארת (specular)
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 1.3,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0x00FFFFFF), Color(0x8FFFFFFF), Color(0x00FFFFFF)],
              ),
            ),
          ),
        ),
        // ברק-זכוכית חולף
        if (sweepActive) Positioned.fill(child: CustomPaint(painter: _Sweep(sweepX))),
      ],
    );
  }
}

// טבעת-קונכית: SweepGradient מסתובב — bloom מטושטש + קו-חד.
class _GlowRing extends CustomPainter {
  _GlowRing(this.t, {required this.enabled});
  final double t;
  final bool enabled;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rr = RRect.fromRectAndRadius(
        rect.deflate(0.8), const Radius.circular(GoldButton._radius));
    final shader = SweepGradient(
      transform: GradientRotation(t * 2 * math.pi),
      colors: const [
        GoldButton._ringLo,
        GoldButton._ringCyan,
        GoldButton._ringHi,
        GoldButton._ringMag,
        GoldButton._ringLo,
      ],
      stops: const [0, 0.28, 0.5, 0.76, 1],
    ).createShader(rect);
    final a = enabled ? 1.0 : 0.4;
    canvas
      ..drawRRect(
        rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..shader = shader
          ..color = Colors.white.withValues(alpha: a)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      )
      ..drawRRect(
        rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..shader = shader,
      );
  }

  @override
  bool shouldRepaint(covariant _GlowRing old) => old.t != t || old.enabled != enabled;
}

// חלקיקי-נצנוץ: נקודות זעירות דטרמיניסטיות שמהבהבות ונעות מעט.
class _Sparkles extends CustomPainter {
  _Sparkles(this.t);
  final double t;
  static const int _n = 16;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var i = 0; i < _n; i++) {
      final fi = i / _n;
      final bx = ((i * 73) % 100) / 100.0;
      final by = ((i * 149) % 100) / 100.0;
      final drift = math.sin((t + fi) * 2 * math.pi) * 0.02;
      final x = ((bx + t * 0.06 + drift) % 1.0) * size.width;
      final y = (by * 0.7 + 0.15) * size.height;
      final tw = 0.5 + 0.5 * math.sin((t * 2 + fi) * 2 * math.pi);
      final r = 0.5 + 1.1 * tw;
      paint.color = Colors.white.withValues(alpha: 0.05 + 0.22 * tw);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _Sparkles old) => old.t != t;
}

// ברק-זכוכית: פס-אור אלכסוני שחולף לרוחב.
class _Sweep extends CustomPainter {
  _Sweep(this.x);
  final double x;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.width * x;
    final bandW = size.width * 0.3;
    final rect = Rect.fromLTWH(center - bandW, 0, bandW * 2, size.height);
    final shader = const LinearGradient(
      colors: [Color(0x00FFFFFF), Color(0x2EFFFFFF), Color(0x00FFFFFF)],
    ).createShader(rect);
    canvas
      ..save()
      ..transform((Matrix4.identity()..rotateZ(-0.3)).storage)
      ..drawRect(
        Rect.fromLTWH(center - bandW, -size.height, bandW * 2, size.height * 3),
        Paint()..shader = shader,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(covariant _Sweep old) => old.x != x;
}
