// 🌲 חולל-ידני (רגע-אמת §20-ב): משחק-idle "גידול-יער" — הורכב מאטומי-המדף שלנו
// (BareStat×2 + RippleButton×2) + glue-מסגרת (Timer/setState — לא-אטום, ההודאה-הישרה).
// אף אטום לא נפסל; שולבו כמה עד שהיכולת (idle-loop קליק+אוטו+שדרוג) הושגה.
import 'dart:async';
import 'package:flutter/material.dart';
import '../dart-ui-bs/bare_stat.dart';
import '../dart-ui-bs/ripple_button.dart';

class GenForestGame extends StatefulWidget {
  const GenForestGame({super.key});
  @override
  State<GenForestGame> createState() => _GenForestGameState();
}

class _GenForestGameState extends State<GenForestGame> {
  double _seeds = 0;
  int _trees = 0;
  double _autoRate = 0;
  bool _boughtAuto = false;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    // לולאת-ה-idle: כל שנייה מוסיפה זרעים לפי הקצב-האוטומטי (0 עד שקונים שדרוג).
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_autoRate > 0) setState(() => _grow(_autoRate));
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  void _grow(double amount) {
    _seeds += amount;
    _trees = _seeds ~/ 100; // כל 100 זרעים ⇒ עץ (התקדמות)
  }

  void _plant() => setState(() => _grow(1)); // קליק ⇒ +1 זרע
  void _buyAuto() {
    if (_seeds >= 50 && !_boughtAuto) {
      setState(() {
        _seeds -= 50;
        _autoRate += 1;
        _boughtAuto = true;
        _trees = _seeds ~/ 100;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1E12),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // מונים — אטום-המדף BareStat (value+label), נתוני-אמת מהמצב
              BareStat(
                value: _seeds.floor().toString(),
                label: '🌱 זרעים',
                inkColor: const Color(0xFF8CE99A),
                mutedColor: const Color(0xFF3E5C46),
              ),
              const SizedBox(height: 16),
              BareStat(
                value: _trees.toString(),
                label: '🌳 עצים ביער',
                inkColor: const Color(0xFF69DB7C),
                mutedColor: const Color(0xFF3E5C46),
              ),
              const SizedBox(height: 32),
              // קליק-שתילה — אטום-המדף RippleButton, onPressed מחווט למכניקה
              RippleButton(
                label: '🌱 שתול זרע',
                height: 64,
                radius: 18,
                accentColor: const Color(0xFF2F9E44),
                baseColor: const Color(0xFF163A22),
                onPressed: _plant,
              ),
              const SizedBox(height: 16),
              // שדרוג — כפתור שני, מגודר-מצב (עלות 50, פעם-אחת)
              RippleButton(
                label: _boughtAuto ? '✅ משקה-אוטומטי פעיל' : '⚙️ קנה משקה-אוטומטי (50 זרעים)',
                height: 56,
                radius: 14,
                accentColor: _boughtAuto ? const Color(0xFF4B6A54) : const Color(0xFF66A80F),
                baseColor: const Color(0xFF163A22),
                onPressed: _buyAuto,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
