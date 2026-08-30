// 🎨 חוט-תצוגה · Countdown — שעון-ספירה-לאחור M:SS (חוק-1/חוק-5).
// המנוע: הזמן יורד מהיעד ל-0 ומתחיל מחדש (AnimationController); פורמט דקות:שניות.
// אפס-דאטה — גובה · יעד-שניות · צבע-מספר/טקסט/רקע מוזרקים בחיווט.
import 'package:flutter/material.dart';
class Countdown extends StatefulWidget {
  const Countdown({required this.height, required this.target, required this.radius,
    required this.accentColor, required this.baseColor, required this.fillColor, super.key});
  final double height; final int target; final double radius;
  final Color accentColor, baseColor, fillColor;
  @override State<Countdown> createState() => _CountdownState();
}
class _CountdownState extends State<Countdown> with SingleTickerProviderStateMixin {
  late final int _total = widget.target < 1 ? 60 : widget.target;
  late final AnimationController _c = AnimationController(vsync: this, duration: Duration(seconds: _total))..repeat();
  @override void dispose() { _c.dispose(); super.dispose(); }
  String _fmt(int s) => '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  @override Widget build(BuildContext context) => Container(
    height: widget.height, alignment: Alignment.center,
    decoration: BoxDecoration(color: widget.fillColor, borderRadius: BorderRadius.circular(widget.radius)),
    child: AnimatedBuilder(animation: _c, builder: (context, _) {
      final left = (_total * (1 - _c.value)).ceil();
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.timer_outlined, color: widget.accentColor, size: widget.height * 0.3),
        const SizedBox(width: 10),
        Text(_fmt(left), style: TextStyle(color: widget.accentColor, fontSize: widget.height * 0.42,
          fontWeight: FontWeight.w900, fontFeatures: const [FontFeature.tabularFigures()])),
      ]);
    }));
}
