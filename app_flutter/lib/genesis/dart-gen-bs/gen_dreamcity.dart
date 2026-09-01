// 🌀 עיר-החלומות — החתך-הכי-מורכב, מחווט כולו מפעולות-יסוד קיימות (L29). אפס פעולה-מומצאת.
// כל תת-מערכת = הרכבה של: ממוצע-שכנים (הנוזל) · סכום/מקסימום · ספירה-לפי-מפתח · מעבר-מצב ·
// שכפול/מיזוג-אם-תואם · לוג-שקרים · חיזוי-argmax · לולאת-זמן. כולן פעולות שקיימות באימפריה.
//   1. תושבי-נוזל  → שדה-צפיפות, diffuse/advect/project = ממוצע-שכנים (gen_fluid).
//   2. כלכלה=מזג-אוויר → מדד-מחירים (הילוך-אקראי); עלייה ⇒ חום-אינפלציה מוזרק לשדה.
//   3. התאדות→עננים → תא חם+צפוף חוצה-סף ⇒ ענן נושא הבטחה (מעבר-מצב).
//   4. הצבעה → countBy על הבטחות-העננים ⇒ מנצח משנה פרמטר; העננים יורדים כגשם.
//   5. עצי-חוקים/עלים → עלה=ערך; מתרבה (שכפול), מתמזג-אם-תואם (|Δ|<ε), קמל-על-סתירה.
//   6. שעון-קארמה → לוג-שקרים פר-אזור (max); בחצות הכי-שקרן ⇒ "רחוב" (מכשול חיכוך).
//   7. אורקל → חוזה את השקרן-הבא (argmax היסטורי); התושבים "מתחמקים" ⇒ נבואה-שמגשימה-עצמה.
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../dart-ui-bs/bare_stat.dart';
import '../dart-ui-bs/ripple_button.dart';

class GenDreamCity extends StatefulWidget {
  const GenDreamCity({super.key});
  @override
  State<GenDreamCity> createState() => _GenDreamCityState();
}

class _Cloud {
  _Cloud(this.x, this.y, this.promise);
  double x, y;
  final int promise; // 0..3 — הבטחה פוליטית
}

class _GenDreamCityState extends State<GenDreamCity> {
  static const int N = 48, W = N + 2, R = 6; // R=מספר אזורי-עיר (לקארמה/חיזוי)
  static const double dt = 0.12, diff = 0.00006, visc = 0.00004, fade = 0.985;
  static const int iters = 12;
  final _rnd = math.Random(7);

  late List<double> dens, dens0, heat, heat0, u, v, u0, v0;
  late List<bool> street; // מכשול = "רחוב מודע-לעצמו"
  final List<_Cloud> clouds = [];
  final List<double> leaves = []; // עלים-חוזים (ערך)
  late List<double> lies; // לוג-שקרים פר-אזור (R)
  late List<double> flowHist; // דפוסי-זרימה-של-אתמול פר-אזור (לחיזוי)

  double priceIndex = 1.0, prevPrice = 1.0;
  int ticks = 0, votesWinner = -1, predictedLiar = -1, actualLiar = -1, midnights = 0;
  Timer? _loop;
  Offset? _prev;

  int ix(int i, int j) => i + W * j;
  int regionOf(int i, int j) => ((i * R ~/ N)).clamp(0, R - 1); // עמודות-אזור

  @override
  void initState() {
    super.initState();
    final n = W * W;
    dens = List.filled(n, 0);
    dens0 = List.filled(n, 0);
    heat = List.filled(n, 0);
    heat0 = List.filled(n, 0);
    u = List.filled(n, 0);
    v = List.filled(n, 0);
    u0 = List.filled(n, 0);
    v0 = List.filled(n, 0);
    street = List.filled(n, false);
    lies = List.filled(R, 0);
    flowHist = List.filled(R, 0);
    _loop = Timer.periodic(const Duration(milliseconds: 40), (_) => _step());
  }

  @override
  void dispose() {
    _loop?.cancel();
    super.dispose();
  }

  // ── פעולת-היסוד: ממוצע כל תא עם 4 שכניו (הנוזל) ──
  void _linSolve(List<double> x, List<double> x0, double a, double c) {
    for (var k = 0; k < iters; k++) {
      for (var j = 1; j <= N; j++) {
        for (var i = 1; i <= N; i++) {
          if (street[ix(i, j)]) continue; // רחוב=מכשול
          x[ix(i, j)] = (x0[ix(i, j)] +
                  a * (x[ix(i - 1, j)] + x[ix(i + 1, j)] + x[ix(i, j - 1)] + x[ix(i, j + 1)])) /
              c;
        }
      }
    }
  }

  void _diffuse(List<double> x, List<double> x0, double d) {
    final a = dt * d * N * N;
    _linSolve(x, x0, a, 1 + 4 * a);
  }

  void _advect(List<double> d, List<double> d0, List<double> uu, List<double> vv) {
    final dt0 = dt * N;
    for (var j = 1; j <= N; j++) {
      for (var i = 1; i <= N; i++) {
        var x = i - dt0 * uu[ix(i, j)];
        var y = j - dt0 * vv[ix(i, j)];
        x = x.clamp(0.5, N + 0.5);
        y = y.clamp(0.5, N + 0.5);
        final i0 = x.floor(), i1 = i0 + 1, j0 = y.floor(), j1 = j0 + 1;
        final s1 = x - i0, s0 = 1 - s1, t1 = y - j0, t0 = 1 - t1;
        d[ix(i, j)] = s0 * (t0 * d0[ix(i0, j0)] + t1 * d0[ix(i0, j1)]) +
            s1 * (t0 * d0[ix(i1, j0)] + t1 * d0[ix(i1, j1)]);
      }
    }
  }

  void _project(List<double> uu, List<double> vv, List<double> p, List<double> div) {
    final h = 1.0 / N;
    for (var j = 1; j <= N; j++) {
      for (var i = 1; i <= N; i++) {
        div[ix(i, j)] = -0.5 *
            h *
            (uu[ix(i + 1, j)] - uu[ix(i - 1, j)] + vv[ix(i, j + 1)] - vv[ix(i, j - 1)]);
        p[ix(i, j)] = 0;
      }
    }
    _linSolve(p, div, 1, 4);
    for (var j = 1; j <= N; j++) {
      for (var i = 1; i <= N; i++) {
        uu[ix(i, j)] -= 0.5 * (p[ix(i + 1, j)] - p[ix(i - 1, j)]) / h;
        vv[ix(i, j)] -= 0.5 * (p[ix(i, j + 1)] - p[ix(i, j - 1)]) / h;
      }
    }
  }

  void _step() {
    ticks++;

    // 2. כלכלה=מזג-אוויר — הילוך-אקראי + נטייה מחזורית
    prevPrice = priceIndex;
    priceIndex += (_rnd.nextDouble() - 0.48) * 0.05 + 0.02 * math.sin(ticks / 60);
    priceIndex = priceIndex.clamp(0.3, 3.0);
    final inflating = priceIndex > prevPrice;
    final heatRate = inflating ? (priceIndex - prevPrice) * 40 : 0.0;

    // חום-אינפלציה מוזרק אקראית תחת המדרכות
    if (inflating) {
      for (var k = 0; k < 3; k++) {
        final ci = 1 + _rnd.nextInt(N), cj = 1 + _rnd.nextInt(N);
        heat0[ix(ci, cj)] += heatRate;
      }
    }

    // נוזל: התושבים + החום זורמים (ממוצע-שכנים)
    for (var i = 0; i < u.length; i++) {
      u[i] += dt * u0[i];
      v[i] += dt * v0[i];
      dens[i] += dt * dens0[i];
      heat[i] += dt * heat0[i];
    }
    _diffuse(u0, u, visc);
    _diffuse(v0, v, visc);
    _project(u0, v0, u, v);
    _advect(u, u0, u0, v0);
    _advect(v, v0, u0, v0);
    _project(u, v, u0, v0);
    _diffuse(dens0, dens, diff);
    _advect(dens, dens0, u, v);
    _diffuse(heat0, heat, diff * 2);
    _advect(heat, heat0, u, v);

    // 3. התאדות → עננים: תא חם+צפוף חוצה-סף ⇒ ענן (מעבר-מצב תושב→ענן)
    for (var j = 1; j <= N; j++) {
      for (var i = 1; i <= N; i++) {
        final id = ix(i, j);
        if (dens[id] > 0.35 && heat[id] > 0.6 && clouds.length < 60) {
          clouds.add(_Cloud(i / N, j / N, _rnd.nextInt(4)));
          dens[id] *= 0.4; // התאדה
          lies[regionOf(i, j)] += heat[id] * 0.02; // שקר מצטבר לפי-חום
        }
      }
    }

    // עננים עולים ומתפוגגים
    for (final c in clouds) {
      c.y -= 0.004;
    }
    clouds.removeWhere((c) => c.y < 0.02);

    for (var i = 0; i < dens.length; i++) {
      dens[i] *= fade;
      heat[i] *= 0.97;
      dens0[i] = heat0[i] = u0[i] = v0[i] = 0;
    }

    // 4. הצבעה: כל 90 טיקים — countBy על הבטחות-העננים ⇒ מנצח ⇒ גשם
    if (ticks % 90 == 0 && clouds.isNotEmpty) {
      final tally = List.filled(4, 0);
      for (final c in clouds) {
        tally[c.promise]++;
      }
      var best = 0;
      for (var p = 1; p < 4; p++) {
        if (tally[p] > tally[best]) best = p;
      }
      votesWinner = best;
      // גשם-החלטות: הזרקת-צפיפות ליער + עלה-חוזה חדש (ערך=תוצאת-ההצבעה)
      for (final c in clouds) {
        final ci = (c.x * N).clamp(1, N).toInt(), cj = (c.y * N).clamp(1, N).toInt();
        dens0[ix(ci, cj)] += 8;
      }
      if (leaves.length < 80) leaves.add(best + _rnd.nextDouble());
      clouds.clear();
    }

    // 5. עצי-חוקים/עלים: שכפול · מיזוג-אם-תואם · קמילה-על-סתירה
    if (ticks % 25 == 0 && leaves.isNotEmpty) {
      // מיזוג שכנים-מסכימים (|Δ|<0.15) — מיזוג-אם-תואם
      leaves.sort();
      for (var i = leaves.length - 1; i > 0; i--) {
        if ((leaves[i] - leaves[i - 1]).abs() < 0.15) {
          leaves[i - 1] = (leaves[i] + leaves[i - 1]) / 2; // מיזוג=ממוצע
          leaves.removeAt(i);
        }
      }
      // שכפול (חלוקת-תא) אם יש מקום
      if (leaves.length < 70) {
        final src = leaves[_rnd.nextInt(leaves.length)];
        leaves.add(src + (_rnd.nextDouble() - 0.5) * 0.1);
      }
      // קמילה-על-סתירה (אקראי — פער הבטחה↔מציאות)
      if (leaves.length > 4 && _rnd.nextDouble() < 0.3) leaves.removeAt(_rnd.nextInt(leaves.length));
    }

    // 6+7. מחזור-חצות: אורקל חוזה, ואז הכי-שקרן ⇒ רחוב
    if (ticks % 300 == 0) {
      midnights++;
      // אורקל: חיזוי לפי דפוסי-אתמול (argmax של flowHist)
      predictedLiar = _argmax(flowHist);
      // המציאות: הכי-שקרן עכשיו (argmax lies)
      actualLiar = _argmax(lies);
      // "רחוב": הופך פס-אזור של השקרן למכשול
      final rc = actualLiar;
      for (var j = 1; j <= N; j++) {
        for (var i = 1; i <= N; i++) {
          if (regionOf(i, j) == rc && _rnd.nextDouble() < 0.15) street[ix(i, j)] = true;
        }
      }
      // נבואה-שמגשימה-עצמה: התושבים "מתחמקים" מהאזור-החזוי ⇒ נרשם כדפוס-מחר
      flowHist = List.filled(R, 0);
      for (var r = 0; r < R; r++) {
        flowHist[r] = lies[r] * 0.5 + (r == predictedLiar ? -0.3 : 0.1) * _rnd.nextDouble();
      }
      lies = List.filled(R, 0);
    }

    if (mounted) setState(() {});
  }

  int _argmax(List<double> a) {
    var b = 0;
    for (var i = 1; i < a.length; i++) {
      if (a[i] > a[b]) b = i;
    }
    return b;
  }

  void _inject(Offset local, Size size) {
    final cx = (local.dx / size.width * N).clamp(1, N).toInt();
    final cy = (local.dy / size.height * N).clamp(1, N).toInt();
    dens0[ix(cx, cy)] += 100;
    if (_prev != null) {
      final dx = (local.dx - _prev!.dx) / size.width * N;
      final dy = (local.dy - _prev!.dy) / size.height * N;
      u0[ix(cx, cy)] += dx * 22;
      v0[ix(cx, cy)] += dy * 22;
    }
    _prev = local;
  }

  void _reset() => setState(() {
        for (var i = 0; i < dens.length; i++) {
          dens[i] = heat[i] = u[i] = v[i] = 0;
          street[i] = false;
        }
        clouds.clear();
        leaves.clear();
        lies = List.filled(R, 0);
        priceIndex = 1.0;
      });

  static const _promises = ['🟥 מסים', '🟦 חופש', '🟩 צמיחה', '🟨 סדר'];

  @override
  Widget build(BuildContext context) {
    final econColor = priceIndex > prevPrice ? const Color(0xFFFF922B) : const Color(0xFF51CF66);
    return Scaffold(
      backgroundColor: const Color(0xFF05060A),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
              child: BareStat(
                value: '×${priceIndex.toStringAsFixed(2)}',
                label: '🌀 עיר-חלומות · מדד-כלכלה ${priceIndex > prevPrice ? "📈 אינפלציה" : "📉 קיפאון"} · גרור להזרים רגש',
                inkColor: econColor,
                mutedColor: const Color(0xFF3A3A4A),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _chip('☁️ עננים', '${clouds.length}', const Color(0xFF74C0FC)),
                  _chip('🌳 עלים', '${leaves.length}', const Color(0xFF69DB7C)),
                  _chip('🗳️ הצביע', votesWinner < 0 ? '—' : _promises[votesWinner], const Color(0xFFFFD43B)),
                  _chip('🌙 חצות', '$midnights', const Color(0xFFB197FC)),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final size = Size(c.maxWidth, c.maxHeight);
                  return GestureDetector(
                    onPanStart: (d) => _inject(d.localPosition, size),
                    onPanUpdate: (d) => _inject(d.localPosition, size),
                    onPanEnd: (_) => _prev = null,
                    child: CustomPaint(
                      painter: _CityPainter(dens, heat, street, clouds, W, N),
                      size: Size.infinite,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: BareStat(
                      value: predictedLiar < 0 ? '—' : 'אזור $predictedLiar',
                      label: '🔮 האורקל חוזה שקרן-מחר ${predictedLiar == actualLiar && actualLiar >= 0 ? "✓ צדק" : ""}',
                      inkColor: const Color(0xFFFF6B9D),
                      mutedColor: const Color(0xFF3A2A3A),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 120,
                    child: RippleButton(
                      label: '🧹 אפס',
                      height: 54,
                      radius: 14,
                      accentColor: const Color(0xFF1098AD),
                      baseColor: const Color(0xFF0B2027),
                      onPressed: _reset,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, String value, Color c) => Column(
        children: [
          Text(value, style: TextStyle(color: c, fontSize: 15, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Color(0xFF6A6A7A), fontSize: 10)),
        ],
      );
}

class _CityPainter extends CustomPainter {
  _CityPainter(this.dens, this.heat, this.street, this.clouds, this.w, this.n);
  final List<double> dens, heat;
  final List<bool> street;
  final List<_Cloud> clouds;
  final int w, n;

  @override
  void paint(Canvas canvas, Size size) {
    final cw = size.width / n, ch = size.height / n;
    final p = Paint();
    for (var j = 1; j <= n; j++) {
      for (var i = 1; i <= n; i++) {
        final id = i + w * j;
        if (street[id]) {
          p.color = const Color(0xFF1A1A22); // רחוב מודע-לעצמו
          canvas.drawRect(Rect.fromLTWH((i - 1) * cw, (j - 1) * ch, cw + 0.5, ch + 0.5), p);
          continue;
        }
        final d = dens[id].clamp(0.0, 1.0);
        if (d < 0.02) continue;
        final h = heat[id].clamp(0.0, 1.0);
        // רגש קר=ציאן · חם(אינפלציה)=אדום-זהב
        final cool = const Color(0xFF3BC9DB), hot = const Color(0xFFFF922B);
        final base = Color.lerp(cool, hot, h) ?? cool;
        p.color = Color.lerp(const Color(0xFF0A0E1A), base, d) ?? base;
        canvas.drawRect(Rect.fromLTWH((i - 1) * cw, (j - 1) * ch, cw + 0.5, ch + 0.5), p);
      }
    }
    // עננים
    final cp = Paint()..color = const Color(0x8874C0FC);
    for (final c in clouds) {
      canvas.drawCircle(Offset(c.x * size.width, c.y * size.height), 5, cp);
    }
  }

  @override
  bool shouldRepaint(_CityPainter old) => true;
}
