// 🎨 חוט-תצוגה · OtpInput — תיבות-קוד עם סמן מתקדם (חוק-1/חוק-5).
// המנוע: N תיבות; התיבה-הפעילה זזה במחזור והתיבות מתמלאות (AnimationController).
// אפס-דאטה — גובה · מספר-תיבות · צבע-פעיל/טקסט/רקע מוזרקים בחיווט.
import 'package:flutter/material.dart';
class OtpInput extends StatefulWidget {
  const OtpInput({required this.height, required this.boxes, required this.radius,
    required this.accentColor, required this.baseColor, required this.fillColor, super.key});
  final double height; final int boxes; final double radius;
  final Color accentColor, baseColor, fillColor;
  @override State<OtpInput> createState() => _OtpInputState();
}
class _OtpInputState extends State<OtpInput> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final n = (widget.boxes < 1 ? 1 : widget.boxes).clamp(1, 8);
    return SizedBox(height: widget.height, child: AnimatedBuilder(animation: _c, builder: (context, _) {
      final active = (_c.value * n).floor().clamp(0, n - 1);
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(n, (i) {
        final filled = i < active; final on = i == active;
        return Container(width: widget.height * 0.7, height: widget.height, margin: const EdgeInsets.symmetric(horizontal: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: widget.fillColor, borderRadius: BorderRadius.circular(widget.radius),
            border: Border.all(color: widget.accentColor.withValues(alpha: on ? 1 : (filled ? 0.6 : 0.25)), width: on ? 2 : 1)),
          child: Text(filled ? '•' : '', style: TextStyle(color: widget.baseColor, fontSize: widget.height * 0.4, fontWeight: FontWeight.w900)));
      }));
    }));
  }
}
