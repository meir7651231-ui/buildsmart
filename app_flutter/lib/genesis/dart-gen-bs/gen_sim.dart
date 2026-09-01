// 🔄 מערכת-חיה-מתפתחת · שילוב 3 קטגוריות-אטום קיימות + חיווט. אפס אטום-חדש, אפס אלגוריתם-ביד.
//   • מעבר-מצב:  advanceStatus (אטום-לוגיקה, dart-maor) — pickup→enroute→delivered, ההתפתחות-בין-צעדים.
//   • חשב-והצג:  BareStat (value+label) — מציג את המצב+הערך המתפתחים.
//   • ambient:   GenerativeCanvas · AuroraField · ParticleField (קנבס-מונפש).
//   • חיווט:     Timer מתקדם את המצב · GestureDetector מזריק "זרימה" · הפרמטרים נגזרים מהמצב.
// זו התקרה של שילוב-אטומים: מערכת שמתקדמת·מחשבת·מציגה·מגיבה — לא נוזל-רציף, אך הכל מאטומים קיימים.
import 'dart:async';
import 'package:flutter/material.dart';
import '../dart-maor/advance-status.dart';
import '../dart-ui-bs/generative_canvas.dart';
import '../dart-ui-bs/aurora_field.dart';
import '../dart-ui-bs/particle_field.dart';
import '../dart-ui-bs/bare_stat.dart';
import '../dart-ui-bs/ripple_button.dart';

class GenSim extends StatefulWidget {
  const GenSim({super.key});
  @override
  State<GenSim> createState() => _GenSimState();
}

class _GenSimState extends State<GenSim> {
  // מצב-מתפתח (מחווט) — נגזרות שמוזרקות לאטומים.
  String _phase = 'pickup'; // ← מנוהל ע"י advanceStatus (אטום מעבר-המצב)
  double _flow = 0.2; // ← ערך-זרימה מתפתח, מוצג ב-BareStat
  int _seed = 5, _ticks = 0;
  Timer? _tick;

  static const _phaseLabel = {'pickup': '🟡 איסוף', 'enroute': '🔵 בדרך', 'delivered': '🟢 נמסר'};

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(milliseconds: 700), (_) {
      setState(() {
        _ticks++;
        _flow = (_flow * 0.94).clamp(0.05, 1.0); // דעיכה (חיווט טריוויאלי)
        if (_ticks % 6 == 0) _phase = advanceStatus(_phase); // ← קידום-מצב באטום
      });
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  void _inject(Offset p, Size size) {
    final nx = (p.dx / size.width).clamp(0.0, 1.0);
    setState(() {
      _flow = (_flow + 0.18).clamp(0.05, 1.0);
      _seed = (nx * 89).round() * 131 + _ticks;
    });
  }

  // speed נגזר מהזרימה+המצב (delivered=רגוע, enroute=מהיר)
  double get _speed {
    final base = 0.5 + _flow * 2.5;
    return _phase == 'enroute' ? base * 1.4 : (_phase == 'delivered' ? base * 0.7 : base);
  }

  @override
  Widget build(BuildContext context) {
    final phaseColor = _phase == 'delivered'
        ? const Color(0xFF51CF66)
        : _phase == 'enroute'
            ? const Color(0xFF4DABF7)
            : const Color(0xFFFFD43B);
    const fill = Color(0xFF0A0E14), deep = Color(0xFF162032);
    final density = 12 + (_flow * 34).round();
    return Scaffold(
      backgroundColor: fill,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              // ── אטום חשב-והצג: מציג את המצב+הזרימה המתפתחים ──
              child: BareStat(
                value: '${(_flow * 100).round()}%',
                label: '${_phaseLabel[_phase]} · זרימה מתפתחת · גרור להזרים',
                inkColor: phaseColor,
                mutedColor: const Color(0xFF3A4A5A),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final size = Size(c.maxWidth, c.maxHeight);
                  return GestureDetector(
                    onPanStart: (d) => _inject(d.localPosition, size),
                    onPanUpdate: (d) => _inject(d.localPosition, size),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        GenerativeCanvas(
                          height: double.infinity,
                          cells: density,
                          speed: _speed * 0.6,
                          radius: 0,
                          accentColor: deep,
                          baseColor: fill,
                          fillColor: fill,
                          seed: _seed,
                        ),
                        AuroraField(
                          height: double.infinity,
                          bands: 5,
                          speed: _speed,
                          radius: 0,
                          accentColor: phaseColor,
                          baseColor: deep,
                          fillColor: Colors.transparent,
                          seed: _seed,
                        ),
                        ParticleField(
                          height: double.infinity,
                          dots: density * 4,
                          speed: _speed * 1.3,
                          radius: 0,
                          accentColor: Colors.white,
                          baseColor: phaseColor,
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
              child: RippleButton(
                label: '⏭️ קדם מצב (${_phaseLabel[_phase]})',
                height: 48,
                radius: 14,
                accentColor: phaseColor,
                baseColor: const Color(0xFF11192A),
                onPressed: () => setState(() => _phase = advanceStatus(_phase)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
