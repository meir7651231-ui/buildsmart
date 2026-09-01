// 🌊 משטח-נוזל-חי — הורכב אך-ורק משני-הכלים: אטומי-המדף + חיווט. אפס אטום-חדש, אפס אלגוריתם-ביד.
// הרכבה: שכבות של AuroraField (פסי-גל זורמים) · GenerativeCanvas (שדה-רעש) · ParticleField
// (חלקיקים נודדים) — כל אטום נושא בעצמו את לולאת-ההנפשה (AnimationController) ואת הצייר
// (CustomPainter). המצב (מהירות/צפיפות/seed/גוון) מחווט מ-setState; הכפתורים אטומי-RippleButton.
//
// ⚠️ גבול-אמת (§20-ג · אימות-בייטים): זה משטח-נוזל אורגני-חי — לא סימולציית Navier-Stokes
// אינטראקטיבית משמרת-מסה. נוזל-פיזיקלי-אמת דורש מערך-שדה שמתפתח פריים-לפריים עם תפר-הזרקה;
// אף אחד מ-1332 האטומים לא נושא תפר כזה. זו התקרה הכנה של אטומים+חיווט בלבד — בלי לזייף.
import 'package:flutter/material.dart';
import '../dart-ui-bs/aurora_field.dart';
import '../dart-ui-bs/generative_canvas.dart';
import '../dart-ui-bs/particle_field.dart';
import '../dart-ui-bs/ripple_button.dart';
import '../dart-ui-bs/bare_stat.dart';

class GenFluid extends StatefulWidget {
  const GenFluid({super.key});
  @override
  State<GenFluid> createState() => _GenFluidState();
}

class _GenFluidState extends State<GenFluid> {
  // מצב מחווט — נגזרות שמוזרקות לאטומים (הם חסרי-הקשר; המחולל/הקופסה מזין).
  double _speed = 1.4;
  int _density = 26;
  int _seed = 7;

  void _stir() => setState(() {
        _seed = (_seed * 1103515245 + 12345) & 0x7fffffff; // ערבול-seed דטרמיניסטי
        _density = 14 + (_seed % 34);
        _speed = 0.8 + (_seed % 25) / 10.0;
      });

  void _calm() => setState(() {
        _speed = 0.6;
        _density = 12;
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
                label: '🌊 משטח-נוזל-חי · seed $_seed · צפיפות $_density',
                inkColor: accent,
                mutedColor: const Color(0xFF3A4A50),
              ),
            ),
            // ── משטח-הנוזל: שלוש שכבות-אטום מוערמות, כל אחת עם הלולאה+הצייר שלה ──
            Expanded(
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
                      onPressed: _stir,
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
