// 🎨 חוט-תצוגה · NumberStepper — מונה עם − / + (חוק-1/חוק-5).
// המנוע: כפתורי הגדל/הקטן משנים ערך פנימי. אפס-דאטה — תווית · גובה · ערך-התחלה ·
// צבע-כפתור/מספר/רקע מוזרקים בחיווט.
import 'package:flutter/material.dart';
class NumberStepper extends StatefulWidget {
  const NumberStepper({required this.label, required this.height, required this.target, required this.radius,
    required this.accentColor, required this.baseColor, required this.fillColor, super.key});
  final String label; final double height; final int target; final double radius;
  final Color accentColor, baseColor, fillColor;
  @override State<NumberStepper> createState() => _NumberStepperState();
}
class _NumberStepperState extends State<NumberStepper> {
  late int _v = widget.target;
  Widget _btn(IconData ic, VoidCallback f) => GestureDetector(onTap: f, child: Container(
    width: widget.height, height: widget.height,
    decoration: BoxDecoration(color: widget.accentColor, borderRadius: BorderRadius.circular(widget.radius)),
    child: Icon(ic, color: widget.fillColor)));
  @override Widget build(BuildContext context) => Row(children: [
    Expanded(child: Text(widget.label, style: TextStyle(color: widget.baseColor, fontSize: 15))),
    _btn(Icons.remove, () => setState(() => _v--)),
    Container(width: widget.height * 1.4, alignment: Alignment.center,
      child: Text('$_v', style: TextStyle(color: widget.baseColor, fontSize: 20, fontWeight: FontWeight.w900))),
    _btn(Icons.add, () => setState(() => _v++)),
  ]);
}
