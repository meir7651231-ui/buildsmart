// ✨ פלזמה-חיה · שילוב 5 אטומים מונפשים בשכבות + חיווט-אצבע — הכל משני-הכלים בלבד.
// אפס אטום-חדש, אפס אלגוריתם-ביד. כל אטום נושא לולאת-הנפשה (AnimationController) + צייר (CustomPainter).
// שכבות (אחור→קדמי): GenerativeCanvas (שדה-רעש) · HeatGrid (רשת-נושמת) · AuroraField (פסי-גל) ·
// ParticleField (חלקיקים) · ConfettiBurst (התפרצויות). GestureDetector = חיווט-טהור: מיקום-גרירה⇒seed/
// צפיפות · מהירות-גרירה⇒speed. זהו "עשן/פלזמה נסחפים-ומגיבים" — מושג עכשיו, בלי לחצוב כלום.
import 'package:flutter/material.dart';
import '../dart-ui-bs/generative_canvas.dart';
import '../dart-ui-bs/heat_grid.dart';
import '../dart-ui-bs/aurora_field.dart';
import '../dart-ui-bs/particle_field.dart';
import '../dart-ui-bs/confetti_burst.dart';
import '../dart-ui-bs/ripple_button.dart';
import '../dart-ui-bs/bare_stat.dart';

class GenPlasma extends StatefulWidget {
  const GenPlasma({super.key});
  @override
  State<GenPlasma> createState() => _GenPlasmaState();
}

class _GenPlasmaState extends State<GenPlasma> {
  double _speed = 1.2;
  int _density = 22;
  int _seed = 11;
  Offset? _prev;

  // חיווט-אצבע: מיקום ⇒ seed/צפיפות · מהירות-תנועה ⇒ speed. שינוי-פרמטרים, לא חישוב.
  void _stir(Offset p, Size size) {
    final nx = (p.dx / size.width).clamp(0.0, 1.0);
    final ny = (p.dy / size.height).clamp(0.0, 1.0);
    double vel = 0;
    if (_prev != null) vel = (p - _prev!).distance;
    _prev = p;
    setState(() {
      _seed = (nx * 89).round() * 137 + (ny * 89).round();
      _density = 12 + (nx * 30).round();
      _speed = (0.5 + ny * 1.6 + vel / 35).clamp(0.4, 4.5);
    });
  }

  void _calm() => setState(() {
        _speed = 0.6;
        _density = 12;
        _prev = null;
      });

  void _ignite() => setState(() {
        _seed = (_seed * 1103515245 + 12345) & 0x7fffffff;
        _density = 18 + (_seed % 26);
        _speed = 1.2 + (_seed % 28) / 10.0;
      });

  @override
  Widget build(BuildContext context) {
    const hot = Color(0xFFFF6B6B), warm = Color(0xFFFFA94D), glow = Color(0xFFFFE066);
    const deep = Color(0xFF3B0764), fill = Color(0xFF0A0612);
    return Scaffold(
      backgroundColor: fill,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: BareStat(
                value: '×${_speed.toStringAsFixed(1)}',
                label: '✨ פלזמה-חיה · גרור להצית · 5 שכבות · seed $_seed',
                inkColor: warm,
                mutedColor: const Color(0xFF4A3A55),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final size = Size(c.maxWidth, c.maxHeight);
                  return GestureDetector(
                    onPanStart: (d) => _stir(d.localPosition, size),
                    onPanUpdate: (d) => _stir(d.localPosition, size),
                    onPanEnd: (_) => _prev = null,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        GenerativeCanvas(
                          height: double.infinity,
                          cells: _density,
                          speed: _speed * 0.6,
                          radius: 0,
                          accentColor: deep,
                          baseColor: fill,
                          fillColor: fill,
                          seed: _seed,
                        ),
                        HeatGrid(
                          height: double.infinity,
                          cells: (_density * 0.6).round().clamp(4, 40),
                          radius: 0,
                          accentColor: hot,
                          baseColor: deep,
                          fillColor: Colors.transparent,
                          seed: _seed,
                        ),
                        AuroraField(
                          height: double.infinity,
                          bands: 5,
                          speed: _speed,
                          radius: 0,
                          accentColor: warm,
                          baseColor: deep,
                          fillColor: Colors.transparent,
                          seed: _seed,
                        ),
                        ParticleField(
                          height: double.infinity,
                          dots: _density * 5,
                          speed: _speed * 1.4,
                          radius: 0,
                          accentColor: glow,
                          baseColor: hot,
                          fillColor: Colors.transparent,
                          seed: _seed,
                        ),
                        ConfettiBurst(
                          height: double.infinity,
                          pieces: (_density * 1.5).round(),
                          speed: _speed * 0.9,
                          radius: 0,
                          accentColor: glow,
                          baseColor: warm,
                          mutedColor: hot,
                          fillColor: Colors.transparent,
                          seed: _seed,
                        ),
                      ],
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
                    child: RippleButton(
                      label: '🔥 הצת',
                      height: 48,
                      radius: 14,
                      accentColor: hot,
                      baseColor: const Color(0xFF2A0A2A),
                      onPressed: _ignite,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RippleButton(
                      label: '🌙 הרגע',
                      height: 48,
                      radius: 14,
                      accentColor: deep,
                      baseColor: const Color(0xFF1A0A22),
                      onPressed: _calm,
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
}
