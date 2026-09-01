// 🌊 נוזל-חי — סימולציית Navier-Stokes (Jos Stam, Stable Fluids) הורכבה מאטומי-המדף
// (BareStat/RippleButton לשלד) + הרכבה (solver + CustomPainter + גרירה). אפס אטום-חדש.
import 'dart:async';
import 'package:flutter/material.dart';
import '../dart-ui-bs/bare_stat.dart';
import '../dart-ui-bs/ripple_button.dart';

class GenFluid extends StatefulWidget {
  const GenFluid({super.key});
  @override
  State<GenFluid> createState() => _GenFluidState();
}

class _GenFluidState extends State<GenFluid> {
  static const int N = 64; // רשת NxN (+2 שכבת-גבול)
  static const int W = N + 2;
  static const double dt = 0.12, diff = 0.00005, visc = 0.00003, fade = 0.985;
  static const int iters = 16;

  late List<double> u, v, u0, v0, dens, dens0;
  Timer? _loop;
  Offset? _prev;
  int _frames = 0, _fps = 0;
  late DateTime _fpsMark;

  int ix(int i, int j) => i + W * j;

  @override
  void initState() {
    super.initState();
    final n = W * W;
    u = List<double>.filled(n, 0);
    v = List<double>.filled(n, 0);
    u0 = List<double>.filled(n, 0);
    v0 = List<double>.filled(n, 0);
    dens = List<double>.filled(n, 0);
    dens0 = List<double>.filled(n, 0);
    _fpsMark = DateTime.now();
    _loop = Timer.periodic(const Duration(milliseconds: 33), (_) => _step());
  }

  @override
  void dispose() {
    _loop?.cancel();
    super.dispose();
  }

  void _addSource(List<double> x, List<double> s) {
    for (var i = 0; i < x.length; i++) {
      x[i] += dt * s[i];
    }
  }

  void _setBnd(int b, List<double> x) {
    for (var i = 1; i <= N; i++) {
      x[ix(0, i)] = b == 1 ? -x[ix(1, i)] : x[ix(1, i)];
      x[ix(N + 1, i)] = b == 1 ? -x[ix(N, i)] : x[ix(N, i)];
      x[ix(i, 0)] = b == 2 ? -x[ix(i, 1)] : x[ix(i, 1)];
      x[ix(i, N + 1)] = b == 2 ? -x[ix(i, N)] : x[ix(i, N)];
    }
    x[ix(0, 0)] = 0.5 * (x[ix(1, 0)] + x[ix(0, 1)]);
    x[ix(0, N + 1)] = 0.5 * (x[ix(1, N + 1)] + x[ix(0, N)]);
    x[ix(N + 1, 0)] = 0.5 * (x[ix(N, 0)] + x[ix(N + 1, 1)]);
    x[ix(N + 1, N + 1)] = 0.5 * (x[ix(N, N + 1)] + x[ix(N + 1, N)]);
  }

  void _linSolve(int b, List<double> x, List<double> x0, double a, double c) {
    for (var k = 0; k < iters; k++) {
      for (var j = 1; j <= N; j++) {
        for (var i = 1; i <= N; i++) {
          x[ix(i, j)] = (x0[ix(i, j)] + a * (x[ix(i - 1, j)] + x[ix(i + 1, j)] + x[ix(i, j - 1)] + x[ix(i, j + 1)])) / c;
        }
      }
      _setBnd(b, x);
    }
  }

  void _diffuse(int b, List<double> x, List<double> x0, double d) {
    final a = dt * d * N * N;
    _linSolve(b, x, x0, a, 1 + 4 * a);
  }

  void _advect(int b, List<double> d, List<double> d0, List<double> uu, List<double> vv) {
    final dt0 = dt * N;
    for (var j = 1; j <= N; j++) {
      for (var i = 1; i <= N; i++) {
        var x = i - dt0 * uu[ix(i, j)];
        var y = j - dt0 * vv[ix(i, j)];
        if (x < 0.5) x = 0.5;
        if (x > N + 0.5) x = N + 0.5;
        final i0 = x.floor(), i1 = i0 + 1;
        if (y < 0.5) y = 0.5;
        if (y > N + 0.5) y = N + 0.5;
        final j0 = y.floor(), j1 = j0 + 1;
        final s1 = x - i0, s0 = 1 - s1, t1 = y - j0, t0 = 1 - t1;
        d[ix(i, j)] = s0 * (t0 * d0[ix(i0, j0)] + t1 * d0[ix(i0, j1)]) + s1 * (t0 * d0[ix(i1, j0)] + t1 * d0[ix(i1, j1)]);
      }
    }
    _setBnd(b, d);
  }

  void _project(List<double> uu, List<double> vv, List<double> p, List<double> div) {
    final h = 1.0 / N;
    for (var j = 1; j <= N; j++) {
      for (var i = 1; i <= N; i++) {
        div[ix(i, j)] = -0.5 * h * (uu[ix(i + 1, j)] - uu[ix(i - 1, j)] + vv[ix(i, j + 1)] - vv[ix(i, j - 1)]);
        p[ix(i, j)] = 0;
      }
    }
    _setBnd(0, div);
    _setBnd(0, p);
    _linSolve(0, p, div, 1, 4);
    for (var j = 1; j <= N; j++) {
      for (var i = 1; i <= N; i++) {
        uu[ix(i, j)] -= 0.5 * (p[ix(i + 1, j)] - p[ix(i - 1, j)]) / h;
        vv[ix(i, j)] -= 0.5 * (p[ix(i, j + 1)] - p[ix(i, j - 1)]) / h;
      }
    }
    _setBnd(1, uu);
    _setBnd(2, vv);
  }

  void _step() {
    // velStep
    _addSource(u, u0);
    _addSource(v, v0);
    _diffuse(1, u0, u, visc);
    _diffuse(2, v0, v, visc);
    _project(u0, v0, u, v);
    _advect(1, u, u0, u0, v0);
    _advect(2, v, v0, u0, v0);
    _project(u, v, u0, v0);
    // densStep
    _addSource(dens, dens0);
    _diffuse(0, dens0, dens, diff);
    _advect(0, dens, dens0, u, v);
    for (var i = 0; i < dens.length; i++) {
      dens[i] *= fade;
      u0[i] = 0;
      v0[i] = 0;
      dens0[i] = 0;
    }
    _frames++;
    final now = DateTime.now();
    if (now.difference(_fpsMark).inMilliseconds >= 1000) {
      _fps = _frames;
      _frames = 0;
      _fpsMark = now;
    }
    if (mounted) setState(() {});
  }

  void _inject(Offset local, Size size) {
    final cx = (local.dx / size.width * N).clamp(1, N).toInt();
    final cy = (local.dy / size.height * N).clamp(1, N).toInt();
    dens0[ix(cx, cy)] += 120;
    if (_prev != null) {
      final dx = (local.dx - _prev!.dx) / size.width * N;
      final dy = (local.dy - _prev!.dy) / size.height * N;
      u0[ix(cx, cy)] += dx * 25;
      v0[ix(cx, cy)] += dy * 25;
    }
    _prev = local;
  }

  void _clear() {
    for (var i = 0; i < u.length; i++) {
      u[i] = v[i] = u0[i] = v0[i] = dens[i] = dens0[i] = 0;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: BareStat(value: '$_fps', label: '🌊 נוזל-חי · ${N}² · fps · גרור לצייר', inkColor: const Color(0xFF66D9E8), mutedColor: const Color(0xFF3A4A50)),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final size = Size(c.maxWidth, c.maxHeight);
                  return GestureDetector(
                    onPanStart: (d) => _inject(d.localPosition, size),
                    onPanUpdate: (d) => _inject(d.localPosition, size),
                    onPanEnd: (_) => _prev = null,
                    child: CustomPaint(painter: _FluidPainter(dens, W, N), size: Size.infinite),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: RippleButton(label: '🧹 נקה', height: 48, radius: 14, accentColor: const Color(0xFF1098AD), baseColor: const Color(0xFF0B2027), onPressed: _clear),
            ),
          ],
        ),
      ),
    );
  }
}

class _FluidPainter extends CustomPainter {
  _FluidPainter(this.dens, this.w, this.n);
  final List<double> dens;
  final int w, n;

  @override
  void paint(Canvas canvas, Size size) {
    final cw = size.width / n, ch = size.height / n;
    final paint = Paint();
    for (var j = 1; j <= n; j++) {
      for (var i = 1; i <= n; i++) {
        final d = dens[i + w * j].clamp(0.0, 1.0);
        if (d < 0.01) continue;
        // מיפוי-צבע: כחול→ציאן→לבן לפי צפיפות
        paint.color = Color.lerp(const Color(0xFF0B3D5C), const Color(0xFFE6FCFF), d)!;
        canvas.drawRect(Rect.fromLTWH((i - 1) * cw, (j - 1) * ch, cw + 0.5, ch + 0.5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_FluidPainter old) => true;
}
