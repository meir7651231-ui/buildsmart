// 🌊 משטח-נוזל-חי · שילוב-אטומים + חיווט-אצבע — הכל משני-הכלים בלבד. אפס אטום-חדש, אפס אלגוריתם-ביד.
// הרכבה: שכבות GenerativeCanvas (שדה-רעש) · AuroraField (פסי-גל זורמים) · ParticleField (חלקיקים) —
// כל אטום נושא בעצמו לולאת-הנפשה (AnimationController) + צייר (CustomPainter). שכבת-אצבע (GestureDetector)
// היא חיווט-טהור: מיקום-הגרירה ⇒ seed/צפיפות, מהירות-הגרירה ⇒ speed. ה"ערבוב" הוא שינוי-פרמטרים חי,
// לא חישוב-מספרי חדש. RippleButton/BareStat אטומי-מדף.
//
// ⚠️ גבול-אמת (§20-ג · מדוד-בייטים): זה משטח-חי-מגיב — לא Navier-Stokes משמר-מסה. צעד-שכן-מספרי
// (מערך→מערך עם צימוד-שכנים) לא קיים כאטום (0 במדף) ולכן לא ניתן-לחיווט; זו התקרה של אטומים+חיווט.
import 'package:flutter/material.dart';
import '../dart-ui-bs/generative_canvas.dart';
import '../dart-ui-bs/aurora_field.dart';
import '../dart-ui-bs/particle_field.dart';
import '../dart-ui-bs/ripple_button.dart';
import '../dart-ui-bs/bare_stat.dart';

class GenFluid extends StatefulWidget {
  const GenFluid({super.key});
  @override
  State<GenFluid> createState() => _GenFluidState();
}

class _GenFluidState extends State<GenFluid> {
  // מצב מחווט — נגזרות שמוזרקות לאטומים (הם חסרי-הקשר; החיווט מזין).
  double _speed = 1.2;
  int _density = 22;
  int _seed = 7;
  Offset? _prev;

  // חיווט-אצבע: מיקום ⇒ seed/צפיפות · מהירות-תנועה ⇒ speed. זה שינוי-פרמטרים, לא חישוב.
  void _stir(Offset p, Size size) {
    final nx = (p.dx / size.width).clamp(0.0, 1.0);
    final ny = (p.dy / size.height).clamp(0.0, 1.0);
    double vel = 0;
    if (_prev != null) vel = (p - _prev!).distance;
    _prev = p;
    setState(() {
      _seed = (nx * 97).round() * 131 + (ny * 97).round();
      _density = 12 + (nx * 30).round();
      _speed = (0.5 + ny * 1.5 + vel / 40).clamp(0.4, 4.0);
    });
  }

  void _calm() => setState(() {
        _speed = 0.6;
        _density = 12;
        _prev = null;
      });

  void _shuffle() => setState(() {
        _seed = (_seed * 1103515245 + 12345) & 0x7fffffff;
        _density = 14 + (_seed % 30);
        _speed = 0.8 + (_seed % 25) / 10.0;
      });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF66D9E8), base = Color(0xFF0B3D5C), fill = Color(0xFF06121A);
    return Scaffold(
      backgroundColor: const Color(0xFF06121A),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: BareStat(
                value: '×${_speed.toStringAsFixed(1)}',
                label: '🌊 משטח-נוזל-חי · גרור לערבב · seed $_seed · צפיפות $_density',
                inkColor: accent,
                mutedColor: const Color(0xFF3A4A50),
              ),
            ),
            // ── משטח-הנוזל: שלוש שכבות-אטום מוערמות + שכבת-אצבע (חיווט) מעל ──
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
                          speed: _speed * 0.7,
                          radius: 0,
                          accentColor: base,
                          baseColor: fill,
                          fillColor: fill,
                          seed: _seed,
                        ),
                        AuroraField(
                          height: double.infinity,
                          bands: 6,
                          speed: _speed,
                          radius: 0,
                          accentColor: accent,
                          baseColor: base,
                          fillColor: Colors.transparent,
                          seed: _seed,
                        ),
                        ParticleField(
                          height: double.infinity,
                          dots: _density * 4,
                          speed: _speed * 1.3,
                          radius: 0,
                          accentColor: const Color(0xFFE6FCFF),
                          baseColor: accent,
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
                      label: '🌀 ערבל',
                      height: 48,
                      radius: 14,
                      accentColor: const Color(0xFF1098AD),
                      baseColor: const Color(0xFF0B2027),
                      onPressed: _shuffle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RippleButton(
                      label: '🧘 הרגע',
                      height: 48,
                      radius: 14,
                      accentColor: const Color(0xFF0B7285),
                      baseColor: const Color(0xFF0B2027),
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
